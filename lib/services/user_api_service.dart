import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserApiService {
  static const String _baseUrl = 'http://172.16.44.133:10000/api';
  static const Duration _timeout = Duration(seconds: 30);

  /// Gets user profile data in the exact JSON format required
  static Future<Map<String, dynamic>> getUserProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "name": prefs.getString('user_name') ?? '',
      "age": int.tryParse(prefs.getString('age') ?? '0') ?? 0,
      "sex": prefs.getString('gender') ?? '',
      "height": double.tryParse(prefs.getString('height') ?? '0') ?? 0.0,
      "weight": double.tryParse(prefs.getString('weight') ?? '0') ?? 0.0,
      "location": prefs.getString('location') ?? '',
      "underlying_allergies":
          prefs.getBool('underlying_allergies') == true ? "yes" : "no",
      "drink": prefs.getBool('drink') == true ? "yes" : "no",
      "smoke": prefs.getBool('smoke') == true ? "yes" : "no",
      "t2diabetes": prefs.getBool('t2diabetes') == true ? "yes" : "no",
      "hypertension": prefs.getBool('hypertension') == true ? "yes" : "no",
      "cvd": prefs.getBool('cvd') == true ? "yes" : "no",
    };
  }

  /// Submits user data to the API endpoint as JSON POST request
  static Future<ApiResponse> submitUserData() async {
    try {
      final userData = await getUserProfileData();

      // Validate required fields
      if (userData['name'].toString().isEmpty ||
          userData['age'] == 0 ||
          userData['sex'].toString().isEmpty) {
        return ApiResponse(
          success: false,
          message: 'Missing required fields',
          statusCode: 400,
        );
      }

      // Debug logging for development
      if (kDebugMode) {
        debugPrint('=== API REQUEST ===');
        debugPrint('Endpoint: $_baseUrl/userdata');
        debugPrint('Method: POST');
        debugPrint('Headers: Content-Type: application/json');
        debugPrint('Body: ${json.encode(userData)}');
        debugPrint('==================');
      }

      // Make the POST request
      final response = await http
          .post(
            Uri.parse('$_baseUrl/userdata'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'CareSight-Mobile-App/1.0.0',
            },
            body: json.encode(userData),
          )
          .timeout(_timeout);

      // Debug response
      if (kDebugMode) {
        debugPrint('=== API RESPONSE ===');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Headers: ${response.headers}');
        debugPrint('Body: ${response.body}');
        debugPrint('===================');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success - save submission status
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('user_data_submitted', true);
        await prefs.setString(
          'submission_date',
          DateTime.now().toIso8601String(),
        );
        await prefs.setString('api_response', response.body);

        return ApiResponse(
          success: true,
          message: 'Profile data submitted successfully',
          statusCode: response.statusCode,
          data: response.body.isNotEmpty ? json.decode(response.body) : null,
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
          statusCode: response.statusCode,
          data: response.body.isNotEmpty ? response.body : null,
        );
      }
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('HTTP Client Error: $e');
      }
      return ApiResponse(
        success: false,
        message: 'Network connection error',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      if (kDebugMode) {
        debugPrint('JSON Format Error: $e');
      }
      return ApiResponse(
        success: false,
        message: 'Invalid response format',
        statusCode: 0,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Unexpected Error: $e');
      }
      return ApiResponse(
        success: false,
        message: 'Unexpected error occurred',
        statusCode: 0,
      );
    }
  }

  /// Checks if user data has been successfully submitted
  static Future<bool> isUserDataSubmitted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('user_data_submitted') ?? false;
  }

  /// Gets the submission date if available
  static Future<String?> getSubmissionDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('submission_date');
  }

  /// Gets the last API response if available
  static Future<String?> getLastApiResponse() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_response');
  }

  /// Retries submission if previously failed
  static Future<ApiResponse> retrySubmission() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data_submitted');
    await prefs.remove('submission_date');
    await prefs.remove('api_response');

    return await submitUserData();
  }
}

/// API Response model for better error handling
class ApiResponse {
  final bool success;
  final String message;
  final int statusCode;
  final dynamic data;

  ApiResponse({
    required this.success,
    required this.message,
    required this.statusCode,
    this.data,
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}
