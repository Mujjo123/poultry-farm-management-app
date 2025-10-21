import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/customer_model.dart';
import '../models/transaction_model.dart';

class CustomerExportService {
  
  // Export customer data to Excel
  Future<bool> exportCustomerToExcel(CustomerModel customer, List<TransactionModel> transactions) async {
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Customer_${customer.indexNumber}'];

      // Customer Info Header
      sheetObject.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('F1'));
      sheetObject.cell(CellIndex.indexByString('A1')).value = 
          TextCellValue('Customer #${customer.indexNumber}: ${customer.customerName}');
      
      // Customer Details
      sheetObject.appendRow([
        TextCellValue('Mobile'),
        TextCellValue(customer.mobileNumber),
        TextCellValue(''),
        TextCellValue('Total Purchase'),
        TextCellValue('₹${customer.totalPurchaseAmount.toStringAsFixed(2)}'),
      ]);
      
      sheetObject.appendRow([
        TextCellValue('Transactions'),
        TextCellValue('${customer.totalTransactions}'),
        TextCellValue(''),
        TextCellValue('Total Paid'),
        TextCellValue('₹${customer.totalPaidAmount.toStringAsFixed(2)}'),
      ]);
      
      sheetObject.appendRow([
        TextCellValue('Customer Since'),
        TextCellValue(DateFormat('dd/MM/yyyy').format(customer.firstTransactionDate)),
        TextCellValue(''),
        TextCellValue('Pending'),
        TextCellValue('₹${customer.totalPendingAmount.toStringAsFixed(2)}'),
      ]);
      
      // Empty row
      sheetObject.appendRow([]);
      
      // Transaction headers
      sheetObject.appendRow([
        TextCellValue('Sr.'),
        TextCellValue('Date'),
        TextCellValue('Qty'),
        TextCellValue('Weight (kg)'),
        TextCellValue('Rate (₹/kg)'),
        TextCellValue('Total (₹)'),
        TextCellValue('Paid (₹)'),
        TextCellValue('Pending (₹)'),
        TextCellValue('Prev. Pending (₹)'),
        TextCellValue('Total Pending (₹)'),
      ]);

      // Transaction data
      int srNo = 1;
      for (var txn in transactions) {
        sheetObject.appendRow([
          IntCellValue(srNo),
          TextCellValue(DateFormat('dd/MM/yyyy HH:mm').format(txn.date)),
          IntCellValue(txn.quantity),
          DoubleCellValue(txn.kilogram),
          DoubleCellValue(txn.rate),
          DoubleCellValue(txn.totalAmount),
          DoubleCellValue(txn.paidAmount),
          DoubleCellValue(txn.pendingAmount),
          DoubleCellValue(txn.previousPending),
          DoubleCellValue(txn.totalPending),
        ]);
        srNo++;
      }

      // Save and share
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Customer_${customer.indexNumber}_${customer.customerName}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.xlsx';
      final filePath = '${directory.path}/$fileName';

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Customer #${customer.indexNumber} - ${customer.customerName}',
        text: 'Complete transaction history for ${customer.customerName}',
      );

      return true;
    } catch (e) {
      debugPrint('Error exporting to Excel: $e');
      return false;
    }
  }

  // Export customer data to PDF
  Future<bool> exportCustomerToPdf(CustomerModel customer, List<TransactionModel> transactions) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Mujawar Poultry Farm',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Customer Report',
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Customer Info
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Customer #${customer.indexNumber}',
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          DateFormat('dd/MM/yyyy').format(DateTime.now()),
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    pw.Divider(),
                    _pdfRow('Name:', customer.customerName),
                    _pdfRow('Mobile:', customer.mobileNumber),
                    _pdfRow('Customer Since:', DateFormat('dd MMM yyyy').format(customer.firstTransactionDate)),
                    _pdfRow('Total Transactions:', '${customer.totalTransactions}'),
                    pw.SizedBox(height: 8),
                    pw.Divider(),
                    pw.SizedBox(height: 8),
                    _pdfRow('Total Purchase:', '₹${customer.totalPurchaseAmount.toStringAsFixed(2)}', bold: true),
                    _pdfRow('Total Paid:', '₹${customer.totalPaidAmount.toStringAsFixed(2)}', bold: true),
                    _pdfRow('Total Pending:', '₹${customer.totalPendingAmount.toStringAsFixed(2)}', bold: true),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Transaction Table
              pw.Text(
                'Transaction History',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),
              
              pw.Table.fromTextArray(
                headers: ['Sr.', 'Date', 'Qty', 'Weight', 'Rate', 'Total', 'Paid', 'Pending'],
                data: transactions.asMap().entries.map((entry) {
                  final txn = entry.value;
                  return [
                    '${entry.key + 1}',
                    DateFormat('dd/MM/yy').format(txn.date),
                    '${txn.quantity}',
                    '${txn.kilogram} kg',
                    '₹${txn.rate}',
                    '₹${txn.totalAmount.toStringAsFixed(0)}',
                    '₹${txn.paidAmount.toStringAsFixed(0)}',
                    '₹${txn.pendingAmount.toStringAsFixed(0)}',
                  ];
                }).toList(),
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellHeight: 25,
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                  5: pw.Alignment.centerRight,
                  6: pw.Alignment.centerRight,
                  7: pw.Alignment.centerRight,
                },
              ),
            ];
          },
        ),
      );

      // Save and share
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Customer_${customer.indexNumber}_${customer.customerName}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.pdf';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Customer #${customer.indexNumber} - ${customer.customerName}',
        text: 'PDF report for ${customer.customerName}',
      );

      return true;
    } catch (e) {
      debugPrint('Error exporting to PDF: $e');
      return false;
    }
  }

  pw.Widget _pdfRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Export customer data to CSV
  Future<bool> exportCustomerToCsv(CustomerModel customer, List<TransactionModel> transactions) async {
    try {
      StringBuffer csv = StringBuffer();
      
      // Customer Info
      csv.writeln('Customer #${customer.indexNumber}: ${customer.customerName}');
      csv.writeln('Mobile: ${customer.mobileNumber}');
      csv.writeln('Customer Since: ${DateFormat('dd/MM/yyyy').format(customer.firstTransactionDate)}');
      csv.writeln('Total Transactions: ${customer.totalTransactions}');
      csv.writeln('Total Purchase: ₹${customer.totalPurchaseAmount.toStringAsFixed(2)}');
      csv.writeln('Total Paid: ₹${customer.totalPaidAmount.toStringAsFixed(2)}');
      csv.writeln('Total Pending: ₹${customer.totalPendingAmount.toStringAsFixed(2)}');
      csv.writeln('');
      
      // Headers
      csv.writeln('Sr.,Date,Quantity,Weight (kg),Rate (₹/kg),Total (₹),Paid (₹),Pending (₹),Prev. Pending (₹),Total Pending (₹)');

      // Data rows
      int srNo = 1;
      for (var txn in transactions) {
        csv.writeln(
            '$srNo,${DateFormat('dd/MM/yyyy HH:mm').format(txn.date)},${txn.quantity},${txn.kilogram},${txn.rate},${txn.totalAmount},${txn.paidAmount},${txn.pendingAmount},${txn.previousPending},${txn.totalPending}');
        srNo++;
      }

      // Save and share
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'Customer_${customer.indexNumber}_${customer.customerName}_${DateFormat('ddMMyyyy_HHmmss').format(DateTime.now())}.csv';
      final filePath = '${directory.path}/$fileName';

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsStringSync(csv.toString());

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Customer #${customer.indexNumber} - ${customer.customerName}',
        text: 'CSV export for ${customer.customerName}',
      );

      return true;
    } catch (e) {
      debugPrint('Error exporting to CSV: $e');
      return false;
    }
  }
}
