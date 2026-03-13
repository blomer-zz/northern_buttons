import 'dart:io';
import 'package:flutter/material.dart';
import 'package:northern_buttons/my_dark_theme.dart';
import 'package:northern_buttons/database/database_helper.dart';
import 'package:northern_buttons/screens/main_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // Required before any async work before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // sqflite works natively on Android & iOS.
  // On desktop (Windows, macOS, Linux) we need the FFI implementation.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Open the database now so it's ready when the app loads.
  // On first launch this also creates the tables and seeds data from the CSVs.
  await DatabaseHelper.instance.database;

  // Seed historical invoices outside the DB transaction so any error here
  // doesn't roll back the schema migration. Skips automatically if already done.
  await DatabaseHelper.instance.seedHistoricalInvoices();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: myDarkTheme,
      title: 'Northern Woods Buttons',
      home: MainScreen(),
    );
  }
}
