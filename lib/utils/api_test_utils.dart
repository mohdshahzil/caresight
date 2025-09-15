import 'package:flutter/foundation.dart';
import '../services/user_api_service.dart';

class ApiTestUtils {
  /// Test the API endpoint with sample data
  static Future<void> testApiEndpoint() async {
    if (kDebugMode) {
      debugPrint('🧪 TESTING API ENDPOINT...');

      try {
        final userData = await UserApiService.getUserProfileData();
        debugPrint('📊 Sample User Data:');
        debugPrint(userData.toString());

        final response = await UserApiService.submitUserData();
        debugPrint('📡 API Test Result: ${response.toString()}');

        if (response.success) {
          debugPrint('✅ API TEST PASSED - Data successfully sent to endpoint!');
        } else {
          debugPrint('❌ API TEST FAILED - ${response.message}');
        }
      } catch (e) {
        debugPrint('💥 API TEST ERROR: $e');
      }
    }
  }

  /// Generate sample JSON for testing
  static Map<String, dynamic> getSampleJson() {
    return {
      "name": "John Doe",
      "age": 45,
      "sex": "Male",
      "height": 175.0,
      "weight": 78.5,
      "location": "NY, USA",
      "underlying_allergies": "no",
      "drink": "yes",
      "smoke": "no",
      "t2diabetes": "no",
      "hypertension": "yes",
      "cvd": "no",
    };
  }
}
