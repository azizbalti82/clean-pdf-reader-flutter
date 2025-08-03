import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF1B98FF),
      brightness: Brightness.light,
    ),
    cardColor: Color(0xFF1B98FF).withOpacity(0.05),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(color: Colors.white),
    useMaterial3: true,
  );

  static final darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF2E424E),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: Colors.black,
    cardColor: Color(0xFF2E424E).withOpacity(0.1),
    appBarTheme: AppBarTheme(color: Colors.black),
    useMaterial3: true,
  );
}
