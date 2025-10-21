import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import '../services/customer_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';

class AddPaymentScreen extends StatefulWidget {
  final CustomerModel customer;

  const AddPaymentScreen({super.key, required this.customer});

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final CustomerService _customerService = CustomerService();
  final TextEditingController _amountController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _addPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final paymentAmount = double.parse(_amountController.text);
    
    if (paymentAmount > widget.customer.totalPendingAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment amount cannot exceed pending amount'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Update customer's pending amount
      final newPendingAmount = widget.customer.totalPendingAmount - paymentAmount;
      final newPaidAmount = widget.customer.totalPaidAmount + paymentAmount;

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customer.id)
          .update({
        'totalPaidAmount': newPaidAmount,
        'totalPendingAmount': newPendingAmount,
        'lastTransactionDate': Timestamp.fromDate(DateTime.now()),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Payment of ₹${paymentAmount.toStringAsFixed(2)} added successfully!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer Info Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          '#${widget.customer.indexNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.customer.customerName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.customer.mobileNumber,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Pending Amount Display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Pending Amount',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${widget.customer.totalPendingAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Payment Amount Field
              const Text(
                'Enter Payment Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              CustomTextField(
                controller: _amountController,
                label: 'Payment Amount',
                icon: Icons.currency_rupee,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter payment amount';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount > widget.customer.totalPendingAmount) {
                    return 'Amount cannot exceed ₹${widget.customer.totalPendingAmount.toStringAsFixed(2)}';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Quick Amount Buttons
              const Text(
                'Quick Select',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (widget.customer.totalPendingAmount >= 100)
                    _buildQuickAmountButton(100),
                  if (widget.customer.totalPendingAmount >= 500)
                    _buildQuickAmountButton(500),
                  if (widget.customer.totalPendingAmount >= 1000)
                    _buildQuickAmountButton(1000),
                  _buildQuickAmountButton(
                    widget.customer.totalPendingAmount,
                    label: 'Full Amount',
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _addPayment,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.payment),
                label: Text(_isLoading ? 'Processing...' : 'Add Payment'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Colors.green,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Info Card
              Card(
                color: Colors.blue.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This payment will reduce the customer\'s pending amount',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(double amount, {String? label}) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _amountController.text = amount.toStringAsFixed(2);
        });
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(
        label ?? '₹${amount.toStringAsFixed(0)}',
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
