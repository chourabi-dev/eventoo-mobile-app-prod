import 'package:flutter/material.dart';

class AppTheme {
  // Color palette
  static const primaryColor = Color.fromARGB(255, 99, 156, 255);
  static const secondaryColor = Color.fromARGB(255, 101, 181, 255);
  static const accentColor = Color(0xFF4ECDC4);
  static const backgroundColor = Color(0xFFF5F5F5); // light background
  static const surfaceColor = Color(0xFFFFFFFF); // cards and surfaces
  static const cardColor = Color(0xFFF0F0F0);
  
  // Gradients
  static const primaryGradient = LinearGradient(
    colors: [primaryColor, Color(0xFF8B84FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const secondaryGradient = LinearGradient(
    colors: [secondaryColor, Color(0xFFFF8FA3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const accentGradient = LinearGradient(
    colors: [accentColor, Color(0xFF6FFFE9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const expositionGardien = LinearGradient(
    colors: [Color.fromARGB(255, 205, 192, 78), Color.fromARGB(255, 235, 100, 67)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  

  // Light theme data
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      error: Color(0xFFB00020),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 6,
      shadowColor: primaryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: primaryColor.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      labelStyle: TextStyle(color: Colors.black.withOpacity(0.7)),
      hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
    ),
  );
}
