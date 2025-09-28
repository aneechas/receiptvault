import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';
import '../models/category.dart' as models;
import '../models/receipt.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> syncExpenseToCloud(Expense expense, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(expense.id.toString())
          .set({
        ...expense.toMap(),
        'syncedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to sync expense: $e');
    }
  }

  Future<void> syncCategoryToCloud(models.Category category, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .doc(category.id.toString())
          .set({
        ...category.toMap(),
        'syncedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to sync category: $e');
    }
  }

  Future<void> syncReceiptToCloud(Receipt receipt, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('receipts')
          .doc(receipt.id.toString())
          .set({
        ...receipt.toMap(),
        'syncedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to sync receipt: $e');
    }
  }

  Future<List<Expense>> getExpensesFromCloud(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Expense.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch expenses: $e');
    }
  }

  Future<List<models.Category>> getCategoriesFromCloud(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return models.Category.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<List<Receipt>> getReceiptsFromCloud(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('receipts')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Receipt.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch receipts: $e');
    }
  }

  Future<void> deleteExpenseFromCloud(int expenseId, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .doc(expenseId.toString())
          .delete();
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  Future<void> deleteCategoryFromCloud(int categoryId, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .doc(categoryId.toString())
          .delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  Future<void> deleteReceiptFromCloud(int receiptId, String userId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('receipts')
          .doc(receiptId.toString())
          .delete();
    } catch (e) {
      throw Exception('Failed to delete receipt: $e');
    }
  }

  Stream<List<Expense>> streamExpenses(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Expense.fromMap(data);
      }).toList();
    });
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set(
        {
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<void> syncAllToCloud({
    required String userId,
    required List<Expense> expenses,
    required List<models.Category> categories,
    required List<Receipt> receipts,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final expense in expenses) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('expenses')
            .doc(expense.id.toString());

        batch.set(docRef, {
          ...expense.toMap(),
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }

      for (final category in categories) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('categories')
            .doc(category.id.toString());

        batch.set(docRef, {
          ...category.toMap(),
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }

      for (final receipt in receipts) {
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('receipts')
            .doc(receipt.id.toString());

        batch.set(docRef, {
          ...receipt.toMap(),
          'syncedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to sync all data: $e');
    }
  }

  Future<void> clearCloudData(String userId) async {
    try {
      final batch = _firestore.batch();

      final expensesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('expenses')
          .get();

      for (final doc in expensesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      final categoriesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('categories')
          .get();

      for (final doc in categoriesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      final receiptsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('receipts')
          .get();

      for (final doc in receiptsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear cloud data: $e');
    }
  }
}