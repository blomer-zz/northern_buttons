import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:northern_buttons/database/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

const _dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

Future<void> printCustomerRoutes() async {
  final db = await DatabaseHelper.instance.database;

  final rows = await db.rawQuery('''
    SELECT
      cr.day_of_week,
      cr.route_id,
      cr.stop_order,
      c.store_name
    FROM customer_routes cr
    LEFT JOIN customers c ON cr.customer_id = c.id
    ORDER BY cr.stop_order
  ''');

  // Group rows by day_of_week
  final Map<String, List<Map<String, dynamic>>> grouped = {};
  for (final row in rows) {
    final day = row['day_of_week'] as String? ?? 'Unknown';
    grouped.putIfAbsent(day, () => []).add(Map<String, dynamic>.from(row));
  }

  // Print in Mon → Fri order
  for (final day in _dayOrder) {
    final stops = grouped[day];
    if (stops == null) continue;

    final routeId = stops.first['route_id'] as String? ?? '';
    debugPrint('\n=== $day — $routeId ===');

    for (final stop in stops) {
      final order = stop['stop_order'] ?? '?';
      final name = stop['store_name'] as String? ?? 'Unknown';
      debugPrint('  Stop $order: $name');
    }
  }
}

class RoutesList extends StatefulWidget {
  const RoutesList({super.key});

  @override
  State<RoutesList> createState() => _RoutesListState();
}

class _RoutesListState extends State<RoutesList> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
        ],
      ),
    );
  }
}
