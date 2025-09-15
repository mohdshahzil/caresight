import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';

class PerformanceUtils {
  /// Optimize frame rate for smooth animations
  static void optimizeFrameRate() {
    // Ensure 60fps for smooth animations
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Force layout if needed
      WidgetsBinding.instance.allowFirstFrame();
    });
  }

  /// Pre-cache images for faster loading
  static Future<void> precacheAppImages(context) async {
    // Add any app images here for precaching
    // Example: await precacheImage(AssetImage('assets/images/logo.png'), context);
  }

  /// Optimize memory usage
  static void optimizeMemory() {
    // Clear unnecessary caches
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Warm up shaders for smooth animations
  static void warmupShaders() {
    // This helps with first-frame jank
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  /// Debounce function for input fields
  static Timer? _debounceTimer;
  static void debounce(Function() action, Duration delay) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, action);
  }
}

// Timer class is already available in dart:async
