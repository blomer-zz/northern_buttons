import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:northern_buttons/screens/invoice_screen.dart';
import 'package:northern_buttons/screens/routes_list_screen.dart';
import 'package:northern_buttons/screens/routes_map_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentPageIndex = 0;

  List<Widget> myScreens = [
    InvoiceScreen(),
    RoutesListScreen(),
    RoutesMapScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentPageIndex, children: myScreens),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Invoices',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_shipping_outlined),
            label: 'Routes',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            label: 'Route Map',
          ),
        ],
        //selectedIndex: ,
      ),
    );
  }
}