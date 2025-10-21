import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String customerId;
  final int customerIndex;
  final String customerName;
  final String mobileNumber;
  final int quantity;
  final double kilogram;
  final double rate;
  final double totalAmount;
  final double paidAmount;
  final double pendingAmount;
  final double previousPending;
  final double totalPending;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.customerId,
    required this.customerIndex,
    required this.customerName,
    required this.mobileNumber,
    required this.quantity,
    required this.kilogram,
    required this.rate,
    required this.totalAmount,
    required this.paidAmount,
    required this.pendingAmount,
    required this.previousPending,
    required this.totalPending,
    required this.date,
  });

  // Factory constructor to create from Firestore
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      customerIndex: data['customerIndex'] ?? 0,
      customerName: data['customerName'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      quantity: data['quantity'] ?? 0,
      kilogram: (data['kilogram'] ?? 0).toDouble(),
      rate: (data['rate'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      paidAmount: (data['paidAmount'] ?? 0).toDouble(),
      pendingAmount: (data['pendingAmount'] ?? 0).toDouble(),
      previousPending: (data['previousPending'] ?? 0).toDouble(),
      totalPending: (data['totalPending'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'customerIndex': customerIndex,
      'customerName': customerName,
      'mobileNumber': mobileNumber,
      'quantity': quantity,
      'kilogram': kilogram,
      'rate': rate,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'pendingAmount': pendingAmount,
      'previousPending': previousPending,
      'totalPending': totalPending,
      'date': Timestamp.fromDate(date),
    };
  }

  // Convert to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'customerIndex': customerIndex,
      'customerName': customerName,
      'mobileNumber': mobileNumber,
      'quantity': quantity,
      'kilogram': kilogram,
      'rate': rate,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'pendingAmount': pendingAmount,
      'previousPending': previousPending,
      'totalPending': totalPending,
      'date': date.toIso8601String(),
    };
  }

  // Calculate total amount
  static double calculateTotalAmount(double kilogram, double rate) {
    return kilogram * rate;
  }

  // Calculate pending amount
  static double calculatePendingAmount(double totalAmount, double paidAmount) {
    return totalAmount - paidAmount;
  }

  // Generate SMS message with history
  String generateSmsMessage() {
    return '''Mujawar Poultry Farm
Customer #$customerIndex: $customerName

Current Purchase:
$kilogram kg (Qty: $quantity) @ ₹$rate/kg
Total: ₹${totalAmount.toStringAsFixed(2)}
Paid: ₹${paidAmount.toStringAsFixed(2)}
Pending: ₹${pendingAmount.toStringAsFixed(2)}

Previous Pending: ₹${previousPending.toStringAsFixed(2)}
Total Pending: ₹${totalPending.toStringAsFixed(2)}

Thank you for your business!''';
  }

  @override
  String toString() {
    return 'Transaction(id: $id, customer #$customerIndex: $customerName, total: ₹$totalAmount, pending: ₹$totalPending)';
  }
}
