import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../models/customer_model.dart';
import '../services/database_service.dart';
import '../services/customer_service.dart';
import '../services/sms_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_text_field.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _databaseService = DatabaseService();
  final CustomerService _customerService = CustomerService();
  final SmsService _smsService = SmsService();

  // Controllers
  final _customerNumberController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _quantityController = TextEditingController();
  final _kilogramController = TextEditingController();
  final _rateController = TextEditingController();
  final _paidAmountController = TextEditingController();

  // Customer data
  CustomerModel? _selectedCustomer;
  List<TransactionModel> _customerHistory = [];
  int _nextAvailableNumber = 1;
  bool _isNewCustomer = false;
  
  // Calculated values
  double _totalAmount = 0.0;
  double _pendingAmount = 0.0;
  double _previousPending = 0.0;
  double _totalPending = 0.0;

  bool _isLoading = false;
  bool _loadingCustomer = false;

  @override
  void initState() {
    super.initState();
    
    // Load next available customer number
    _loadNextAvailableNumber();
    
    // Add listeners for auto-calculation
    _kilogramController.addListener(_calculateAmounts);
    _rateController.addListener(_calculateAmounts);
    _paidAmountController.addListener(_calculateAmounts);
    
    // Add listener for customer number to auto-load customer
    _customerNumberController.addListener(_loadCustomerByNumber);
    
    // Add listener for mobile number to check existing customer
    _mobileController.addListener(_checkExistingCustomer);
  }
  
  // Load next available customer number
  Future<void> _loadNextAvailableNumber() async {
    try {
      final allCustomers = await _customerService.searchCustomers('');
      if (allCustomers.isEmpty) {
        setState(() {
          _nextAvailableNumber = 1;
        });
      } else {
        final maxNumber = allCustomers
            .map((c) => c.indexNumber)
            .reduce((a, b) => a > b ? a : b);
        setState(() {
          _nextAvailableNumber = maxNumber + 1;
        });
      }
    } catch (e) {
      setState(() {
        _nextAvailableNumber = 1;
      });
    }
  }

  @override
  void dispose() {
    _customerNumberController.dispose();
    _customerNameController.dispose();
    _mobileController.dispose();
    _quantityController.dispose();
    _kilogramController.dispose();
    _rateController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  // Load customer by customer number
  Future<void> _loadCustomerByNumber() async {
    final customerNumber = _customerNumberController.text.trim();
    
    if (customerNumber.isEmpty) {
      setState(() {
        _selectedCustomer = null;
        _customerHistory = [];
        _previousPending = 0.0;
        _customerNameController.clear();
        _mobileController.clear();
      });
      return;
    }
    
    final customerIndex = int.tryParse(customerNumber);
    if (customerIndex != null && customerIndex > 0) {
      setState(() {
        _loadingCustomer = true;
      });
      
      // Search by customer index
      final allCustomers = await _customerService.searchCustomers('');
      CustomerModel? customer;
      
      try {
        customer = allCustomers.firstWhere(
          (c) => c.indexNumber == customerIndex,
        );
      } catch (e) {
        customer = null;
      }
      
      if (customer != null) {
        // Customer found, load their data
        setState(() {
          _selectedCustomer = customer;
          _customerNameController.text = customer!.customerName;
          _mobileController.text = customer.mobileNumber;
          _previousPending = customer.totalPendingAmount;
        });
        
        // Load customer history
        final history = await _customerService.getCustomerTransactions(customer.id);
        setState(() {
          _customerHistory = history;
          _loadingCustomer = false;
        });
        
        _calculateAmounts();
      } else {
        setState(() {
          _selectedCustomer = null;
          _customerHistory = [];
          _previousPending = 0.0;
          _loadingCustomer = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Customer #$customerNumber not found'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }
  
  // Prepare for adding new customer
  void _prepareNewCustomer() {
    setState(() {
      _isNewCustomer = true;
      _selectedCustomer = null;
      _customerHistory = [];
      _previousPending = 0.0;
      _loadingCustomer = false;
      
      // Set next customer number
      _customerNumberController.text = _nextAvailableNumber.toString();
      
      // Clear other fields
      _customerNameController.clear();
      _mobileController.clear();
    });
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Ready to add Customer #$_nextAvailableNumber'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Focus on name field
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // Check if customer exists by mobile number
  Future<void> _checkExistingCustomer() async {
    final mobile = _smsService.formatPhoneNumber(_mobileController.text);
    
    if (mobile.length == 10) {
      setState(() {
        _loadingCustomer = true;
      });
      
      final customer = await _customerService.getCustomerByMobile(mobile);
      
      if (customer != null) {
        // Customer exists, load their data
        setState(() {
          _selectedCustomer = customer;
          _customerNameController.text = customer.customerName;
          _previousPending = customer.totalPendingAmount;
        });
        
        // Load customer history
        final history = await _customerService.getCustomerTransactions(customer.id);
        setState(() {
          _customerHistory = history;
          _loadingCustomer = false;
        });
        
        _calculateAmounts();
      } else {
        setState(() {
          _selectedCustomer = null;
          _customerHistory = [];
          _previousPending = 0.0;
          _loadingCustomer = false;
        });
      }
    }
  }

  void _calculateAmounts() {
    setState(() {
      final kilogram = double.tryParse(_kilogramController.text) ?? 0.0;
      final rate = double.tryParse(_rateController.text) ?? 0.0;
      final paidAmount = double.tryParse(_paidAmountController.text) ?? 0.0;

      _totalAmount = TransactionModel.calculateTotalAmount(kilogram, rate);
      _pendingAmount = TransactionModel.calculatePendingAmount(_totalAmount, paidAmount);
      _totalPending = _previousPending + _pendingAmount;
    });
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate phone number
    final formattedPhone = _smsService.formatPhoneNumber(_mobileController.text);
    if (!_smsService.isValidPhoneNumber(formattedPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get or create customer
      CustomerModel? customer = _selectedCustomer;
      if (customer == null) {
        customer = await _customerService.getOrCreateCustomer(
          formattedPhone,
          _customerNameController.text.trim(),
        );
        
        if (customer == null) {
          throw Exception('Failed to create customer');
        }
      }
      
      // Create transaction model
      final transaction = TransactionModel(
        id: const Uuid().v4(),
        customerId: customer.id,
        customerIndex: customer.indexNumber,
        customerName: customer.customerName,
        mobileNumber: formattedPhone,
        quantity: int.parse(_quantityController.text),
        kilogram: double.parse(_kilogramController.text),
        rate: double.parse(_rateController.text),
        totalAmount: _totalAmount,
        paidAmount: double.parse(_paidAmountController.text),
        pendingAmount: _pendingAmount,
        previousPending: _previousPending,
        totalPending: _totalPending,
        date: DateTime.now(),
      );

      // Save to database
      final saved = await _databaseService.addTransaction(transaction);

      if (saved) {
        // Update customer totals
        await _customerService.updateCustomerAfterTransaction(
          customer.id,
          _totalAmount,
          double.parse(_paidAmountController.text),
          _pendingAmount,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Transaction saved for Customer #${customer.indexNumber}\nOpening SMS app...'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        
        // Open SMS app
        debugPrint('📨 Opening SMS app...');
        final smsOpened = await _smsService.sendTransactionSms(transaction);
        debugPrint('SMS app opened: $smsOpened');

        if (mounted) {
          if (smsOpened) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('📱 SMS app opened! Please send the message manually.'),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 4),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚠️ Could not open SMS app.\nCustomer #${transaction.customerIndex}: ${transaction.customerName}\nPhone: ${transaction.mobileNumber}'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }

          // Navigate back
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save transaction'),
              backgroundColor: AppColors.error,
            ),
          );
        }
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
        title: const Text(AppStrings.addTransaction),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          children: [
            // Customer Information Section
            const Text(
              'Customer Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Customer Number Field (NEW)
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _customerNumberController,
                    label: 'Customer Number (Optional)',
                    icon: Icons.tag,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: null, // Optional field
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _prepareNewCustomer,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Helper text
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Enter customer # to load OR click "New" for Customer #$_nextAvailableNumber',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _customerNameController,
              label: AppStrings.customerName,
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter customer name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _mobileController,
              label: AppStrings.mobileNumber,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter mobile number';
                }
                if (value.length != 10) {
                  return 'Mobile number must be 10 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Show customer info if exists
            if (_loadingCustomer)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Loading customer info...'),
                    ],
                  ),
                ),
              ),
            
            if (_selectedCustomer != null)
              Card(
                color: Colors.blue.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Customer #${_selectedCustomer!.indexNumber}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildInfoRow('Total Purchases', '₹${_selectedCustomer!.totalPurchaseAmount.toStringAsFixed(2)}'),
                      _buildInfoRow('Total Paid', '₹${_selectedCustomer!.totalPaidAmount.toStringAsFixed(2)}'),
                      _buildInfoRow('Previous Pending', '₹${_selectedCustomer!.totalPendingAmount.toStringAsFixed(2)}', 
                        isHighlight: _selectedCustomer!.totalPendingAmount > 0),
                      _buildInfoRow('Total Transactions', '${_selectedCustomer!.totalTransactions}'),
                      
                      if (_customerHistory.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const SizedBox(height: 12),
                        const Text(
                          'Recent Transactions:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...(_customerHistory.take(3).map((txn) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${txn.kilogram} kg @ ₹${txn.rate}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                '₹${txn.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ))),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Transaction Details Section
            const Text(
              'Transaction Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            CustomTextField(
              controller: _quantityController,
              label: AppStrings.quantity,
              icon: Icons.shopping_basket,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _kilogramController,
              label: AppStrings.kilogram,
              icon: Icons.scale,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter kilogram';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _rateController,
              label: AppStrings.rate,
              icon: Icons.currency_rupee,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter rate';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Calculated Amounts Section
            const Text(
              'Amount Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Total Amount (Read-only)
            Card(
              color: AppColors.success.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calculate, color: AppColors.success),
                        SizedBox(width: 12),
                        Text(
                          AppStrings.totalAmount,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${_totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _paidAmountController,
              label: AppStrings.paidAmount,
              icon: Icons.payment,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter paid amount';
                }
                final paid = double.tryParse(value) ?? 0;
                if (paid > _totalAmount) {
                  return 'Paid amount cannot exceed total amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Pending Amount (Read-only)
            Card(
              color: AppColors.pending.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.pending_actions, color: AppColors.pending),
                        SizedBox(width: 12),
                        Text(
                          'Current Pending',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '₹${_pendingAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pending,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Previous Pending (if exists)
            if (_previousPending > 0)
              Card(
                color: Colors.orange.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.history, color: Colors.orange),
                          SizedBox(width: 12),
                          Text(
                            'Previous Pending',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${_previousPending.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            if (_previousPending > 0)
              const SizedBox(height: 12),
            
            // Total Pending (if exists)
            if (_previousPending > 0)
              Card(
                color: Colors.red.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance_wallet, color: Colors.red),
                          SizedBox(width: 12),
                          Text(
                            'Total Pending',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '₹${_totalPending.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveTransaction,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isLoading ? 'Saving...' : 'Save Transaction'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
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
                        'SMS app will open automatically. Please send the message to customer.',
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
    );
  }
  
  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isHighlight ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
