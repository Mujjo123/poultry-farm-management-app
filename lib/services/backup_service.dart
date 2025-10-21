import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/transaction_model.dart';

class BackupService {
  // Export transactions to Excel
  Future<bool> exportToExcel(List<TransactionModel> transactions) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Transactions'];

      // Add headers
      sheetObject.appendRow([
        TextCellValue('Sr. No.'),
        TextCellValue('Date'),
        TextCellValue('Customer Name'),
        TextCellValue('Customer Name'),
        TextCellValue('Mobile Number'),
        TextCellValue('Quantity'),
        TextCellValue('Kilogram (kg)'),
        TextCellValue('Rate (₹/kg)'),
        TextCellValue('Total Amount (₹)'),
        TextCellValue('Paid Amount (₹)'),
        TextCellValue('Pending Amount (₹)'),
        TextCellValue('Previous Pending (₹)'),
        TextCellValue('Total Pending (₹)'),
      ]);

      // Style header row
      for (var i = 0; i < 12; i++) {
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.green,
          fontColorHex: ExcelColor.white,
        );
      }

      // Add data rows
      int srNo = 1;
      for (var transaction in transactions) {
        sheetObject.appendRow([
          IntCellValue(srNo),
          TextCellValue(DateFormat('dd/MM/yyyy').format(transaction.date)),
          TextCellValue(transaction.customerName),
          TextCellValue(transaction.mobileNumber),
          IntCellValue(transaction.quantity),
          DoubleCellValue(transaction.kilogram),
          DoubleCellValue(transaction.rate),
          DoubleCellValue(transaction.totalAmount),
          DoubleCellValue(transaction.paidAmount),
          DoubleCellValue(transaction.pendingAmount),
          DoubleCellValue(transaction.previousPending),
          DoubleCellValue(transaction.totalPending),
        ]);
        srNo++;
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Poultry_Transactions_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';
      final filePath = '${directory.path}/$fileName';

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      // Share file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Poultry Farm Transactions Backup',
        text: 'Transaction data exported from Mujawar Poultry Farm',
      );

      return true;
    } catch (e) {
      print('Error exporting to Excel: $e');
      return false;
    }
  }

  // Export transactions to JSON
  Future<bool> exportToJson(List<TransactionModel> transactions) async {
    try {
      // Convert transactions to JSON
      List<Map<String, dynamic>> jsonData = transactions.map((t) => t.toJson()).toList();
      String jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Poultry_Transactions_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.json';
      final filePath = '${directory.path}/$fileName';

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsStringSync(jsonString);

      // Share file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Poultry Farm Transactions Backup (JSON)',
        text: 'Transaction data exported from Mujawar Poultry Farm',
      );

      return true;
    } catch (e) {
      print('Error exporting to JSON: $e');
      return false;
    }
  }

  // Export to CSV
  Future<bool> exportToCsv(List<TransactionModel> transactions) async {
    try {
      StringBuffer csv = StringBuffer();
      
      // Headers
      csv.writeln('Sr. No.,Date,Customer Name,Mobile Number,Quantity,Kilogram (kg),Rate (₹/kg),Total Amount (₹),Paid Amount (₹),Pending Amount (₹),Previous Pending (₹),Total Pending (₹)');

      // Data rows
      int srNo = 1;
      for (var transaction in transactions) {
        csv.writeln(
            '$srNo,${DateFormat('dd/MM/yyyy').format(transaction.date)},${transaction.customerName},${transaction.mobileNumber},${transaction.quantity},${transaction.kilogram},${transaction.rate},${transaction.totalAmount},${transaction.paidAmount},${transaction.pendingAmount},${transaction.previousPending},${transaction.totalPending}');
        srNo++;
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Poultry_Transactions_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.csv';
      final filePath = '${directory.path}/$fileName';

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsStringSync(csv.toString());

      // Share file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Poultry Farm Transactions Backup (CSV)',
        text: 'Transaction data exported from Mujawar Poultry Farm',
      );

      return true;
    } catch (e) {
      print('Error exporting to CSV: $e');
      return false;
    }
  }
}
