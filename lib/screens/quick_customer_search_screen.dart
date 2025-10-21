import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/customer_model.dart';
import '../services/customer_service.dart';
import '../utils/constants.dart';
import 'customer_detail_screen.dart';
import 'add_payment_screen.dart';

class QuickCustomerSearchScreen extends StatefulWidget {
  const QuickCustomerSearchScreen({super.key});

  @override
  State<QuickCustomerSearchScreen> createState() => _QuickCustomerSearchScreenState();
}

class _QuickCustomerSearchScreenState extends State<QuickCustomerSearchScreen> {
  final CustomerService _customerService = CustomerService();
  final TextEditingController _searchController = TextEditingController();
  
  CustomerModel? _foundCustomer;
  bool _isSearching = false;
  bool _notFound = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchCustomer() async {
    final query = _searchController.text.trim();
    
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter customer number or mobile'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _foundCustomer = null;
      _notFound = false;
    });

    try {
      CustomerModel? customer;
      
      // Check if it's a number (customer index)
      final customerIndex = int.tryParse(query);
      if (customerIndex != null) {
        // Search by index number
        final allCustomers = await _customerService.searchCustomers('');
        customer = allCustomers.firstWhere(
          (c) => c.indexNumber == customerIndex,
          orElse: () => allCustomers.first, // Will be null if not found
        );
        if (customer.indexNumber != customerIndex) {
          customer = null;
        }
      } else {
        // Search by mobile number
        customer = await _customerService.getCustomerByMobile(query);
      }

      setState(() {
        _foundCustomer = customer;
        _notFound = customer == null;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _notFound = true;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Customer Search'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Instructions
            Card(
              color: Colors.blue.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'How to Search',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Enter Customer Number (e.g., 1, 2, 3...)\n• Or enter Mobile Number (10 digits)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Search Field
            TextField(
              controller: _searchController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Customer # or Mobile Number',
                hintText: 'Enter 1, 2, 3... or 10-digit mobile',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _foundCustomer = null;
                            _notFound = false;
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: (_) => _searchCustomer(),
              onChanged: (_) {
                setState(() {
                  _notFound = false;
                  _foundCustomer = null;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Search Button
            ElevatedButton.icon(
              onPressed: _isSearching ? null : _searchCustomer,
              icon: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.search),
              label: Text(_isSearching ? 'Searching...' : 'Search Customer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Results Section
            if (_notFound)
              Card(
                color: Colors.red.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Customer Not Found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No customer found with "${_searchController.text}"',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            if (_foundCustomer != null)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _foundCustomer!.totalPendingAmount > 0
                        ? Colors.red
                        : Colors.green,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Customer Header
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          '#${_foundCustomer!.indexNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        _foundCustomer!.customerName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            _foundCustomer!.mobileNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      
                      const Divider(height: 32),
                      
                      // Customer Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            'Transactions',
                            '${_foundCustomer!.totalTransactions}',
                            Icons.receipt,
                            Colors.blue,
                          ),
                          _buildStatColumn(
                            'Total Sales',
                            '₹${_foundCustomer!.totalPurchaseAmount.toStringAsFixed(0)}',
                            Icons.shopping_cart,
                            Colors.green,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Pending Amount Highlight
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _foundCustomer!.totalPendingAmount > 0
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _foundCustomer!.totalPendingAmount > 0
                                ? Colors.red
                                : Colors.green,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Pending Amount:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${_foundCustomer!.totalPendingAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _foundCustomer!.totalPendingAmount > 0
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomerDetailScreen(
                                      customer: _foundCustomer!,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.visibility),
                              label: const Text('View Details'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _foundCustomer!.totalPendingAmount > 0
                                  ? () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AddPaymentScreen(
                                            customer: _foundCustomer!,
                                          ),
                                        ),
                                      );
                                      
                                      if (result == true) {
                                        // Refresh customer data
                                        _searchCustomer();
                                      }
                                    }
                                  : null,
                              icon: const Icon(Icons.payment),
                              label: const Text('Add Payment'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: Colors.green,
                                disabledBackgroundColor: Colors.grey,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildStatColumn(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
