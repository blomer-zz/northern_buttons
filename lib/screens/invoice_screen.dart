import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:northern_buttons/invoice_maker.dart';
import 'package:northern_buttons/database/database_helper.dart';

class InvoiceScreen extends StatefulWidget {
  final Customer? preselectedCustomer;

  const InvoiceScreen({super.key, this.preselectedCustomer});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  List<Customer> _customers = [];
  Customer? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final customers = await DatabaseHelper.instance.getCustomers();
    final preselected = widget.preselectedCustomer;
    setState(() {
      _customers = customers;
      if (preselected != null) {
        final matches = customers.where((c) => c.id == preselected.id);
        if (matches.isNotEmpty) _selectedCustomer = matches.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use the selected customer's pricing category, or 'default' if none chosen yet
    final pricingCategory = _selectedCustomer?.pricingCategory ?? 'default';

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 120.0,
        leading: Text(
          DateFormat.Hm().format(DateTime.now()),
          style: GoogleFonts.roboto(fontSize: 20),
        ),
        centerTitle: true,
        title: Text(DateFormat.MEd().format(DateTime.now())),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: DropdownButtonFormField<Customer>(
              initialValue: _selectedCustomer,
              hint: const Text('Select a store...'),
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              items: _customers.map((customer) {
                return DropdownMenuItem<Customer>(
                  value: customer,
                  child: Text(
                    customer.storeName,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (Customer? selected) {
                setState(() {
                  _selectedCustomer = selected;
                });
              },
            ),
          ),
        ),
      ),
      body: InvoiceMaker(pricingCategory: pricingCategory),
    );
  }
}
