import 'package:flutter/material.dart';

class AppColors {
  // Healthcare psychology colors
  static const Color primaryGreen = Color(0xFF2E7D32); // Trust, health, balance
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color accentGreen = Color(0xFF81C784);

  static const Color primaryBlue = Color(0xFF1976D2); // Trust, reliability
  static const Color lightBlue = Color(0xFF42A5F5);
  static const Color accentBlue = Color(0xFF90CAF9);

  // Risk alert colors
  static const Color riskOrange = Color(0xFFFF9800);
  static const Color riskYellow = Color(0xFFFFC107);
  static const Color highRisk = Color(0xFFE53935);

  // Neutral colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFBDBDBD);

  // Risk level colors
  static const Color lowRisk = Color(0xFF4CAF50);
  static const Color mediumRisk = Color(0xFFFF9800);
  static const Color highRiskColor = Color(0xFFE53935);

  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, lightGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient riskGradient = LinearGradient(
    colors: [riskOrange, riskYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
