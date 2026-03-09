import 'package:flutter/material.dart';

final ThemeData myDarkTheme = ThemeData(
  // Use Material 3 theming
  useMaterial3: true,
  
  // Define the base color scheme with a seed color and dark brightness.
  // This automatically generates a full harmonious dark color palette.
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 174, 1, 1), // Your brand's primary color
    brightness: Brightness.dark,
  ),
  
  // Customize the typography
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: Colors.white70, // Use soft white for dark mode text
    ),
    bodyLarge: TextStyle(
      fontSize: 40,
      color: Colors.white,
    ),
    // ... define other text styles like titleLarge, bodyMedium, etc.
  ),

  // Customize individual widget themes for consistency
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[900], // A soft dark grey instead of pure black
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),


  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.black,
    foregroundColor: const Color.fromARGB(255, 123, 0, 0),
  ),

  // Customize elevated buttons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  ),

  // Customize input fields
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color.fromARGB(255, 158, 1, 1), width: 2),
    ),
    fillColor: Colors.grey[800],
    filled: true,
  ),
);
