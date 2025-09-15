import 'dart:convert';
import 'package:flutter/foundation.dart';

void logDebug(String message, [Map<String, dynamic>? data]) {
  _log('DEBUG', message, data);
}

void logWarn(String message, [Map<String, dynamic>? data]) {
  _log('WARN', message, data);
}

void logError(String message, [Map<String, dynamic>? data]) {
  _log('ERROR', message, data);
}

void _log(String level, String message, Map<String, dynamic>? data) {
  final ts = DateTime.now().toIso8601String();
  final base = '[$level][$ts] $message';
  if (data == null || data.isEmpty) {
    debugPrint(base);
    return;
  }
  try {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    // Split long logs to avoid truncation in some consoles
    const chunk = 800;
    for (int i = 0; i < jsonStr.length; i += chunk) {
      debugPrint('$base ${jsonStr.substring(i, (i + chunk).clamp(0, jsonStr.length))}');
    }
  } catch (_) {
    debugPrint('$base ${data.toString()}');
  }
}


