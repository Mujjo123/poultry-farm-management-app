import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final int indexNumber;
  final String customerName;
  final String mobileNumber;
  final double totalPurchaseAmount;
  final double totalPaidAmount;
  final double totalPendingAmount;
  final int totalTransactions;
  final DateTime firstTransactionDate;
  final DateTime lastTransactionDate;

  CustomerModel({
    required this.id,
    required this.indexNumber,
    required this.customerName,
    required this.mobileNumber,
    required this.totalPurchaseAmount,
    required this.totalPaidAmount,
    required this.totalPendingAmount,
    required this.totalTransactions,
    required this.firstTransactionDate,
    required this.lastTransactionDate,
  });

  // Factory constructor to create from Firestore
  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CustomerModel(
      id: doc.id,
      indexNumber: data['indexNumber'] ?? 0,
      customerName: data['customerName'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      totalPurchaseAmount: (data['totalPurchaseAmount'] ?? 0).toDouble(),
      totalPaidAmount: (data['totalPaidAmount'] ?? 0).toDouble(),
      totalPendingAmount: (data['totalPendingAmount'] ?? 0).toDouble(),
      totalTransactions: data['totalTransactions'] ?? 0,
      firstTransactionDate: (data['firstTransactionDate'] as Timestamp).toDate(),
      lastTransactionDate: (data['lastTransactionDate'] as Timestamp).toDate(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'indexNumber': indexNumber,
      'customerName': customerName,
      'mobileNumber': mobileNumber,
      'totalPurchaseAmount': totalPurchaseAmount,
      'totalPaidAmount': totalPaidAmount,
      'totalPendingAmount': totalPendingAmount,
      'totalTransactions': totalTransactions,
      'firstTransactionDate': Timestamp.fromDate(firstTransactionDate),
      'lastTransactionDate': Timestamp.fromDate(lastTransactionDate),
    };
  }

  // Convert to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'indexNumber': indexNumber,
      'customerName': customerName,
      'mobileNumber': mobileNumber,
      'totalPurchaseAmount': totalPurchaseAmount,
      'totalPaidAmount': totalPaidAmount,
      'totalPendingAmount': totalPendingAmount,
      'totalTransactions': totalTransactions,
      'firstTransactionDate': firstTransactionDate.toIso8601String(),
      'lastTransactionDate': lastTransactionDate.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Customer #$indexNumber: $customerName (₹$totalPendingAmount pending)';
  }
}
