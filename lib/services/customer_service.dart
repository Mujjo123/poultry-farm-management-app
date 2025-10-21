import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../models/transaction_model.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get or create customer
  Future<CustomerModel?> getOrCreateCustomer(String mobileNumber, String customerName) async {
    try {
      // Check if customer exists by mobile number
      final querySnapshot = await _firestore
          .collection('customers')
          .where('mobileNumber', isEqualTo: mobileNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Customer exists, return it
        return CustomerModel.fromFirestore(querySnapshot.docs.first);
      } else {
        // Create new customer
        return await _createNewCustomer(mobileNumber, customerName);
      }
    } catch (e) {
      debugPrint('Error getting/creating customer: $e');
      return null;
    }
  }

  // Create new customer with index number
  Future<CustomerModel?> _createNewCustomer(String mobileNumber, String customerName) async {
    try {
      debugPrint('📝 Creating new customer: $customerName ($mobileNumber)');
      
      // Get the highest index number
      int newIndexNumber = 1;
      try {
        final querySnapshot = await _firestore
            .collection('customers')
            .orderBy('indexNumber', descending: true)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final lastCustomer = CustomerModel.fromFirestore(querySnapshot.docs.first);
          newIndexNumber = lastCustomer.indexNumber + 1;
          debugPrint('Last customer index: ${lastCustomer.indexNumber}, New index: $newIndexNumber');
        } else {
          debugPrint('No existing customers, starting with index 1');
        }
      } catch (e) {
        // If orderBy fails (e.g., no index or empty collection), use 1
        debugPrint('⚠️ Could not get last index (probably first customer): $e');
        newIndexNumber = 1;
      }

      final now = DateTime.now();
      final docRef = _firestore.collection('customers').doc();

      final customer = CustomerModel(
        id: docRef.id,
        indexNumber: newIndexNumber,
        customerName: customerName,
        mobileNumber: mobileNumber,
        totalPurchaseAmount: 0,
        totalPaidAmount: 0,
        totalPendingAmount: 0,
        totalTransactions: 0,
        firstTransactionDate: now,
        lastTransactionDate: now,
      );

      debugPrint('💾 Saving customer to Firestore...');
      await docRef.set(customer.toMap());
      debugPrint('✅ New customer created: #$newIndexNumber - $customerName');

      return customer;
    } catch (e) {
      debugPrint('❌ Error creating customer: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Update customer after transaction
  Future<bool> updateCustomerAfterTransaction(
    String customerId,
    double transactionTotal,
    double transactionPaid,
    double transactionPending,
  ) async {
    try {
      final docRef = _firestore.collection('customers').doc(customerId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        return false;
      }

      final customer = CustomerModel.fromFirestore(docSnapshot);

      await docRef.update({
        'totalPurchaseAmount': customer.totalPurchaseAmount + transactionTotal,
        'totalPaidAmount': customer.totalPaidAmount + transactionPaid,
        'totalPendingAmount': customer.totalPendingAmount + transactionPending,
        'totalTransactions': customer.totalTransactions + 1,
        'lastTransactionDate': Timestamp.fromDate(DateTime.now()),
      });

      debugPrint('✅ Customer updated: ${customer.customerName}');
      return true;
    } catch (e) {
      debugPrint('Error updating customer: $e');
      return false;
    }
  }

  // Get customer by ID
  Future<CustomerModel?> getCustomerById(String customerId) async {
    try {
      final docSnapshot = await _firestore.collection('customers').doc(customerId).get();
      if (docSnapshot.exists) {
        return CustomerModel.fromFirestore(docSnapshot);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting customer by ID: $e');
      return null;
    }
  }

  // Get customer by mobile number
  Future<CustomerModel?> getCustomerByMobile(String mobileNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('customers')
          .where('mobileNumber', isEqualTo: mobileNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return CustomerModel.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting customer by mobile: $e');
      return null;
    }
  }

  // Get customer transactions
  Future<List<TransactionModel>> getCustomerTransactions(String customerId) async {
    try {
      final querySnapshot = await _firestore
          .collection('transactions')
          .where('customerId', isEqualTo: customerId)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting customer transactions: $e');
      return [];
    }
  }

  // Get all customers
  Stream<List<CustomerModel>> getAllCustomersStream() {
    return _firestore
        .collection('customers')
        .orderBy('indexNumber', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CustomerModel.fromFirestore(doc))
            .toList());
  }

  // Search customers by name or number
  Future<List<CustomerModel>> searchCustomers(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('customers')
          .orderBy('indexNumber')
          .get();

      return querySnapshot.docs
          .map((doc) => CustomerModel.fromFirestore(doc))
          .where((customer) =>
              customer.customerName.toLowerCase().contains(query.toLowerCase()) ||
              customer.mobileNumber.contains(query) ||
              customer.indexNumber.toString().contains(query))
          .toList();
    } catch (e) {
      debugPrint('Error searching customers: $e');
      return [];
    }
  }
}
