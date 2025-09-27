import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/category.dart' as models;
import '../services/database_service.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseService _databaseService;

  List<Expense> _expenses = [];
  List<models.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Filters
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  ExpenseProvider(this._databaseService) {
    _initialize();
  }

  // Getters
  List<Expense> get expenses => _expenses;
  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  Future<void> _initialize() async {
    await loadCategories();
    await loadExpenses();
  }

  // Load all expenses
  Future<void> loadExpenses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _expenses = await _databaseService.getExpenses(
        category: _selectedCategory,
        startDate: _startDate,
        endDate: _endDate,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _categories = await _databaseService.getCategories();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Add expense
  Future<bool> addExpense(Expense expense) async {
    try {
      final id = await _databaseService.insertExpense(expense);
      if (id > 0) {
        await loadExpenses();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update expense
  Future<bool> updateExpense(Expense expense) async {
    try {
      final result = await _databaseService.updateExpense(expense);
      if (result > 0) {
        await loadExpenses();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete expense
  Future<bool> deleteExpense(int id) async {
    try {
      final result = await _databaseService.deleteExpense(id);
      if (result > 0) {
        await loadExpenses();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Filter by category
  void filterByCategory(String? category) {
    _selectedCategory = category;
    loadExpenses();
  }

  // Filter by date range
  void filterByDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    loadExpenses();
  }

  // Clear filters
  void clearFilters() {
    _selectedCategory = null;
    _startDate = null;
    _endDate = null;
    loadExpenses();
  }

  // Get total expenses for current month
  Future<double> getMonthlyTotal() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    return await _databaseService.getTotalExpenses(
      startDate: firstDayOfMonth,
      endDate: lastDayOfMonth,
    );
  }

  // Get category totals
  Future<Map<String, double>> getCategoryTotals() async {
    return await _databaseService.getCategoryTotals(
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  // Get expenses for specific month
  Future<List<Expense>> getExpensesForMonth(int year, int month) async {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    return await _databaseService.getExpenses(
      startDate: firstDay,
      endDate: lastDay,
    );
  }

  // Get recent expenses
  List<Expense> getRecentExpenses({int limit = 10}) {
    if (_expenses.isEmpty) return [];
    return _expenses.take(limit).toList();
  }

  // Get expense by ID
  Future<Expense?> getExpenseById(int id) async {
    return await _databaseService.getExpenseById(id);
  }
}