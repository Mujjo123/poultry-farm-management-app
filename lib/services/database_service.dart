import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'transactions';

  // Add new transaction
  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      await _firestore.collection(collectionName).add(transaction.toMap());
      return true;
    } catch (e) {
      print('Error adding transaction: $e');
      return false;
    }
  }

  // Get all transactions (latest first)
  Stream<List<TransactionModel>> getAllTransactions() {
    return _firestore
        .collection(collectionName)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  // Get transactions by date range
  Stream<List<TransactionModel>> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate) {
    return _firestore
        .collection(collectionName)
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  // Get today's transactions
  Stream<List<TransactionModel>> getTodayTransactions() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getTransactionsByDateRange(startOfDay, endOfDay);
  }

  // Get transactions by customer mobile
  Stream<List<TransactionModel>> getTransactionsByCustomer(String mobileNumber) {
    return _firestore
        .collection(collectionName)
        .where('mobileNumber', isEqualTo: mobileNumber)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromFirestore(doc))
            .toList());
  }

  // Update transaction
  Future<bool> updateTransaction(String id, TransactionModel transaction) async {
    try {
      await _firestore.collection(collectionName).doc(id).update(transaction.toMap());
      return true;
    } catch (e) {
      print('Error updating transaction: $e');
      return false;
    }
  }

  // Delete transaction
  Future<bool> deleteTransaction(String id) async {
    try {
      await _firestore.collection(collectionName).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting transaction: $e');
      return false;
    }
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      final transactions = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();

      double totalSales = 0;
      double totalPending = 0;
      Set<String> uniqueCustomers = {};

      for (var transaction in transactions) {
        totalSales += transaction.totalAmount;
        totalPending += transaction.pendingAmount;
        uniqueCustomers.add(transaction.mobileNumber);
      }

      return {
        'totalSales': totalSales,
        'totalPending': totalPending,
        'totalCustomers': uniqueCustomers.length,
        'totalTransactions': transactions.length,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {
        'totalSales': 0.0,
        'totalPending': 0.0,
        'totalCustomers': 0,
        'totalTransactions': 0,
      };
    }
  }

  // Get all transactions for export
  Future<List<TransactionModel>> getAllTransactionsForExport() async {
    try {
      final snapshot = await _firestore
          .collection(collectionName)
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting transactions for export: $e');
      return [];
    }
  }
}
