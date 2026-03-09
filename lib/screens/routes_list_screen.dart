import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:northern_buttons/database/database_helper.dart';
import 'package:northern_buttons/models/routes_list_print.dart';
import 'package:northern_buttons/screens/invoice_screen.dart';
import 'package:url_launcher/url_launcher.dart';

const _dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

class RoutesListScreen extends StatefulWidget {
  const RoutesListScreen({super.key});

  @override
  State<RoutesListScreen> createState() => _RoutesListScreenState();
}

class _RoutesListScreenState extends State<RoutesListScreen> {
  List<Map<String, dynamic>> dbDropDownRoutes = [];
  List<Map<String, dynamic>> _routeStops = [];
  String dropDownValue = '';

  @override
  void initState() {
    super.initState();
    printCustomerRoutes();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery(
      'SELECT DISTINCT route_id, day_of_week FROM customer_routes',
    );

    final sorted = [...rows];
    sorted.sort((a, b) {
      final ai = _dayOrder.indexOf(a['day_of_week'] as String? ?? '');
      final bi = _dayOrder.indexOf(b['day_of_week'] as String? ?? '');
      return ai.compareTo(bi);
    });

    setState(() {
      dbDropDownRoutes = sorted;
      if (sorted.isNotEmpty) {
        dropDownValue = sorted.first['route_id'] as String? ?? '';
      }
    });

    if (sorted.isNotEmpty) {
      _loadStops(sorted.first['route_id'] as String? ?? '');
    }
  }

  Future<void> _loadStops(String routeId) async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.rawQuery('''
      SELECT c.*, cr.stop_order, cr.id as cr_id, cr.route_id as cr_route_id, cr.day_of_week as cr_day_of_week
      FROM customer_routes cr
      LEFT JOIN customers c ON cr.customer_id = c.id
      WHERE cr.route_id = ?
      ORDER BY cr.stop_order
    ''', [routeId]);

    setState(() {
      _routeStops = rows;
    });
  }

  Future<void> _showEditRouteDialog(Map<String, dynamic> row) async {
    final stopOrderController = TextEditingController(
      text: '${row['stop_order'] ?? ''}',
    );
    String selectedDay = row['cr_day_of_week'] as String? ?? _dayOrder.first;
    String selectedRouteId = row['cr_route_id'] as String? ?? '';

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(
                row['store_name'] as String? ?? '',
                style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: stopOrderController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stop order'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey(selectedDay),
                    initialValue: selectedDay,
                    decoration: const InputDecoration(labelText: 'Day of week'),
                    items: _dayOrder.map((day) {
                      return DropdownMenuItem(value: day, child: Text(day));
                    }).toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      setDialogState(() => selectedDay = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: TextEditingController(text: selectedRouteId)
                      ..selection = TextSelection.collapsed(offset: selectedRouteId.length),
                    decoration: const InputDecoration(labelText: 'Route ID'),
                    onChanged: (val) => selectedRouteId = val,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final newStopOrder = int.tryParse(stopOrderController.text);
                    final db = await DatabaseHelper.instance.database;
                    await db.update(
                      'customer_routes',
                      {
                        'stop_order': newStopOrder,
                        'day_of_week': selectedDay,
                        'route_id': selectedRouteId,
                      },
                      where: 'id = ?',
                      whereArgs: [row['cr_id']],
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    _loadStops(dropDownValue);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _openMaps(Map<String, dynamic> row) async {
    final lat = row['latitude'];
    final lng = row['longitude'];
    final address = row['address'] as String? ?? '';

    Uri uri;
    if (address.isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
      );
    } else if (lat != null && lng != null) {
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    } else {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showCustomerDetails(Map<String, dynamic> row) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row['store_name'] as String? ?? '',
                    style: GoogleFonts.roboto(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  if (row['address'] != null)
                    _detailRow(Icons.location_on_outlined, row['address'] as String),
                  if (row['store_phone'] != null)
                    _detailRow(Icons.phone_outlined, row['store_phone'] as String),
                  if (row['manager_name'] != null)
                    _detailRow(Icons.person_outlined, 'Manager: ${row['manager_name']}'),
                  if (row['manager_phone'] != null)
                    _detailRow(Icons.phone_outlined, 'Manager phone: ${row['manager_phone']}'),
                  if (row['contact_person'] != null)
                    _detailRow(Icons.contacts_outlined, 'Contact: ${row['contact_person']}'),
                  if (row['contact_phone'] != null)
                    _detailRow(Icons.phone_outlined, 'Contact phone: ${row['contact_phone']}'),
                  if (row['store_email'] != null)
                    _detailRow(Icons.email_outlined, row['store_email'] as String),
                  if (row['notes'] != null) ...[
                    const SizedBox(height: 12),
                    Text('Notes', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      row['notes'] as String,
                      style: GoogleFonts.roboto(fontSize: 14),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: GoogleFonts.roboto(fontSize: 15))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                DateFormat.Hm().format(DateTime.now()),
                style: GoogleFonts.roboto(fontSize: 20),
              ),
              Text(
                DateFormat.MEd().format(DateTime.now()),
                style: GoogleFonts.roboto(fontSize: 20),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: DropdownButtonFormField<String>(
              key: ValueKey(dropDownValue),
              initialValue: dropDownValue.isEmpty ? null : dropDownValue,
              items: dbDropDownRoutes.map((row) {
                final label = '${row['day_of_week']} — ${row['route_id']}';
                return DropdownMenuItem<String>(
                  value: row['route_id'] as String,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => dropDownValue = value);
                _loadStops(value);
              },
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Colors.amber, width: 2.0),
              ),
              child: _routeStops.isEmpty
                  ? const Center(child: Text('Select a route above'))
                  : ListView.builder(
                      itemCount: _routeStops.length,
                      itemBuilder: (context, index) {
                        final row = _routeStops[index];
                        final customer = Customer.fromMap(
                          Map<String, dynamic>.from(row)..remove('stop_order'),
                        );
                        return ListTile(
                          leading: GestureDetector(
                            onTap: () {
                              // TODO: edit stop route order
                            },
                            child: CircleAvatar(
                              child: Text('${row['stop_order'] ?? '?'}'),
                            ),
                          ),
                          title: GestureDetector(
                            onTap: () => _showCustomerDetails(row),
                            child: Text(
                              row['store_name'] as String? ?? '',
                              style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _showEditRouteDialog(row),
                              ),
                              IconButton(
                                icon: const Icon(Icons.receipt_long_outlined),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => InvoiceScreen(
                                        preselectedCustomer: customer,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.directions_car),
                                onPressed: () => _openMaps(row),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
