import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/transaction_model.dart';

class SmsService {
  static const platform = MethodChannel('com.mujawar.poultry_farm/sms');

  // Request SMS permission
  Future<bool> requestSmsPermission() async {
    try {
      var status = await Permission.sms.status;
      debugPrint('Current SMS permission status: $status');
      
      if (status.isDenied || status.isLimited) {
        debugPrint('Requesting SMS permission...');
        status = await Permission.sms.request();
        debugPrint('Permission request result: $status');
      }
      
      if (status.isPermanentlyDenied) {
        debugPrint('⚠️ SMS permission permanently denied. Opening settings...');
        await openAppSettings();
        return false;
      }
      
      debugPrint('SMS permission granted: ${status.isGranted}');
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting SMS permission: $e');
      return false;
    }
  }

  // Send SMS to customer using SMS app
  Future<bool> sendTransactionSms(TransactionModel transaction) async {
    try {
      // Prepare SMS message
      String message = transaction.generateSmsMessage();
      String phoneNumber = transaction.mobileNumber;
      
      // Remove any formatting from phone number
      phoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      debugPrint('📱 Opening SMS app for: $phoneNumber');
      debugPrint('📝 Message: $message');

      // Use platform channel to open SMS app
      try {
        final result = await platform.invokeMethod('openSMSApp', {
          'phoneNumber': phoneNumber,
          'message': message,
        });
        
        debugPrint('✅ SMS app opened: $result');
        return result == 'success';
      } on PlatformException catch (e) {
        debugPrint('❌ Platform error: ${e.code} - ${e.message}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error opening SMS app: $e');
      return false;
    }
  }
  
  // Fallback method: Send via platform channel
  Future<bool> _sendViaPlatformChannel(String phoneNumber, String message) async {
    try {
      debugPrint('🔄 Trying platform channel method...');
      
      final result = await platform.invokeMethod('sendSMS', {
        'phoneNumber': phoneNumber,
        'message': message,
      });
      
      debugPrint('✅ Platform channel result: $result');
      return true;
    } on PlatformException catch (e) {
      debugPrint('❌ Platform error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return false;
    }
  }

  // Send custom SMS
  Future<bool> sendCustomSms(String phoneNumber, String message) async {
    try {
      // Remove any formatting from phone number
      phoneNumber = formatPhoneNumber(phoneNumber);
      
      // Add country code if not present
      if (!phoneNumber.startsWith('91') && phoneNumber.length == 10) {
        phoneNumber = '91$phoneNumber';
      }

      // Create SMS URI
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        queryParameters: {'body': message},
      );

      // Launch SMS app
      if (await canLaunchUrl(smsUri)) {
        return await launchUrl(smsUri);
      } else {
        // Fallback to platform channel
        return await _sendViaPlatformChannel(phoneNumber, message);
      }
    } catch (e) {
      debugPrint('Error sending custom SMS: $e');
      return false;
    }
  }

  // Validate phone number
  bool isValidPhoneNumber(String phoneNumber) {
    // Check if it's a valid 10-digit Indian phone number
    final regex = RegExp(r'^[6-9]\d{9}$');
    return regex.hasMatch(phoneNumber);
  }

  // Format phone number (remove spaces, dashes, etc.)
  String formatPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  }
}
