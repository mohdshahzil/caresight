import 'package:flutter/material.dart';

class AppColors {
  // Brand colors (updated to #002F38 palette)
  static const Color primaryGreen = Color(0xFF002F38); // base brand color
  static const Color lightGreen = Color(
    0xFF004954,
  ); // lighter shade for gradients/surfaces
  static const Color accentGreen = Color(
    0xFF006B7C,
  ); // accent shade for emphasis

  static const Color primaryBlue = Color(0xFF002F38); // align blues to brand
  static const Color lightBlue = Color(0xFF004954);
  static const Color accentBlue = Color(0xFF006B7C);

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
