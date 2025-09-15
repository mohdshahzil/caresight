import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'screens/landing_screen.dart';

void main() {
  runApp(const CareSightApp());
}

class CareSightApp extends StatelessWidget {
  const CareSightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CareSight',
      theme: AppTheme.lightTheme,
      home: const LandingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
