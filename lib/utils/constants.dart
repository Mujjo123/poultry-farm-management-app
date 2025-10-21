import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color accent = Color(0xFF8BC34A);
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color pending = Color(0xFFF57C00);
}

class AppStrings {
  static const String appName = 'Mujawar Poultry Farm';
  static const String adminLogin = 'Admin Login';
  static const String dashboard = 'Dashboard';
  static const String addTransaction = 'Add Transaction';
  static const String transactionHistory = 'Transaction History';
  static const String totalSales = 'Total Sales';
  static const String totalPending = 'Total Pending';
  static const String totalCustomers = 'Total Customers';
  static const String logout = 'Logout';
  static const String backup = 'Backup Data';
  
  // Form Fields
  static const String customerName = 'Customer Name';
  static const String mobileNumber = 'Mobile Number';
  static const String quantity = 'Quantity';
  static const String kilogram = 'Kilogram (kg)';
  static const String rate = 'Rate (₹/kg)';
  static const String totalAmount = 'Total Amount';
  static const String paidAmount = 'Paid Amount';
  static const String pendingAmount = 'Pending Amount';
  static const String date = 'Date';
  
  // Messages
  static const String transactionAdded = 'Transaction added successfully!';
  static const String smsSent = 'SMS sent to customer';
  static const String smsError = 'Failed to send SMS';
  static const String loginError = 'Invalid credentials';
  static const String fillAllFields = 'Please fill all required fields';
}

class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
}
