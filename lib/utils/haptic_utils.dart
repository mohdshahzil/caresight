import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticUtils {
  static Future<void> lightImpact() async {
    try {
      if (await Vibration.hasVibrator()) {
        HapticFeedback.lightImpact();
        await Vibration.vibrate(duration: 50, amplitude: 50);
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      // Fallback to system haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  static Future<void> mediumImpact() async {
    try {
      if (await Vibration.hasVibrator()) {
        HapticFeedback.mediumImpact();
        await Vibration.vibrate(duration: 100, amplitude: 100);
      } else {
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      HapticFeedback.mediumImpact();
    }
  }

  static Future<void> heavyImpact() async {
    try {
      if (await Vibration.hasVibrator()) {
        HapticFeedback.heavyImpact();
        await Vibration.vibrate(duration: 150, amplitude: 150);
      } else {
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
    }
  }

  static Future<void> selectionClick() async {
    try {
      if (await Vibration.hasVibrator()) {
        HapticFeedback.selectionClick();
        await Vibration.vibrate(duration: 25, amplitude: 30);
      } else {
        HapticFeedback.selectionClick();
      }
    } catch (e) {
      HapticFeedback.selectionClick();
    }
  }

  static Future<void> success() async {
    try {
      if (await Vibration.hasVibrator()) {
        // Double tap for success
        await Vibration.vibrate(duration: 100, amplitude: 80);
        await Future.delayed(const Duration(milliseconds: 50));
        await Vibration.vibrate(duration: 100, amplitude: 80);
      } else {
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      HapticFeedback.mediumImpact();
    }
  }

  static Future<void> error() async {
    try {
      if (await Vibration.hasVibrator()) {
        // Triple tap for error
        for (int i = 0; i < 3; i++) {
          await Vibration.vibrate(duration: 80, amplitude: 120);
          if (i < 2) await Future.delayed(const Duration(milliseconds: 80));
        }
      } else {
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
    }
  }
}
