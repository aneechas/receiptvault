import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../models/receipt.dart';
import '../config/constants.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initialize();
    return _database!;
  }

  Future<Database> initialize() async {
    String path = join(await getDatabasesPath(), AppConstants.databaseName);
    
    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE ${AppConstants.categoriesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        budgetLimit REAL,
        isDefault INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create expenses table
    await db.execute('''
      CREATE TABLE ${AppConstants.expensesTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT,
        receiptPath TEXT,
        currency TEXT NOT NULL DEFAULT 'GBP',
        merchant TEXT,
        tags TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Create receipts table
    await db.execute('''
      CREATE TABLE ${AppConstants.receiptsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT NOT NULL,
        ocrText TEXT,
        extractedData TEXT,
        scannedAt TEXT NOT NULL,
        expenseId INTEGER,
        isProcessed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (expenseId) REFERENCES ${AppConstants.expensesTable} (id)
      )
    ''');

    // Create indexes for better performance
    await db.execute('''
      CREATE INDEX idx_expenses_date ON ${AppConstants.expensesTable} (date)
    ''');
    
    await db.execute('''
      CREATE INDEX idx_expenses_category ON ${AppConstants.expensesTable} (category)
    ''');

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final batch = db.batch();
    
    for (String categoryName in AppConstants.defaultCategories) {
      final category = Category(
        name: categoryName,
        icon: AppConstants.categoryIcons[categoryName] ?? '📌',
        isDefault: true,
      );
      batch.insert(AppConstants.categoriesTable, category.toMap());
    }
    
    await batch.commit(noResult: true);
  }

  // CRUD Operations for Expenses
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert(AppConstants.expensesTable, expense.toMap());
  }

  Future<List<Expense>> getExpenses({
    int? limit,
    int? offset,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (category != null) {
      whereClause = 'category = ?';
      whereArgs.add(category);
    }
    
    if (startDate != null && endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'date BETWEEN ? AND ?';
      whereArgs.add(startDate.toIso8601String());
      whereArgs.add(endDate.toIso8601String());
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.expensesTable,
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'date DESC',
      limit: limit,
      offset: offset,
    );
    
    return List.generate(maps.length, (i) => Expense.fromMap(maps[i]));
  }

  Future<Expense?> getExpenseById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.expensesTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return Expense.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      AppConstants.expensesTable,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.expensesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations for Categories
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert(AppConstants.categoriesTable, category.toMap());
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.categoriesTable,
      orderBy: 'name ASC',
    );
    
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      AppConstants.categoriesTable,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.categoriesTable,
      where: 'id = ? AND isDefault = 0',
      whereArgs: [id],
    );
  }

  // CRUD Operations for Receipts
  Future<int> insertReceipt(Receipt receipt) async {
    final db = await database;
    return await db.insert(AppConstants.receiptsTable, receipt.toMap());
  }

  Future<List<Receipt>> getReceipts({int? limit, int? offset}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.receiptsTable,
      orderBy: 'scannedAt DESC',
      limit: limit,
      offset: offset,
    );
    
    return List.generate(maps.length, (i) => Receipt.fromMap(maps[i]));
  }

  Future<Receipt?> getReceiptById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.receiptsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (maps.isNotEmpty) {
      return Receipt.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateReceipt(Receipt receipt) async {
    final db = await database;
    return await db.update(
      AppConstants.receiptsTable,
      receipt.toMap(),
      where: 'id = ?',
      whereArgs: [receipt.id],
    );
  }

  Future<int> deleteReceipt(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.receiptsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Analytics queries
  Future<Map<String, double>> getCategoryTotals({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (startDate != null && endDate != null) {
      whereClause = 'date BETWEEN ? AND ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }
    
    final List<Map<String, dynamic>> result = await db.rawQuery(
      '''
      SELECT category, SUM(amount) as total
      FROM ${AppConstants.expensesTable}
      ${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
      GROUP BY category
      ''',
      whereArgs,
    );
    
    Map<String, double> totals = {};
    for (var row in result) {
      totals[row['category']] = row['total'] as double;
    }
    
    return totals;
  }

  Future<double> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (startDate != null && endDate != null) {
      whereClause = 'WHERE date BETWEEN ? AND ?';
      whereArgs = [startDate.toIso8601String(), endDate.toIso8601String()];
    }
    
    final result = await db.rawQuery(
      '''
      SELECT SUM(amount) as total
      FROM ${AppConstants.expensesTable}
      $whereClause
      ''',
      whereArgs,
    );
    
    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as double;
    }
    return 0.0;
  }

  // Cleanup
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}