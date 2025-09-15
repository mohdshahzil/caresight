import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeminiService {
  static const String _apiKey = 'AIzaSyB75CXjVkrGpvEkULCpfN6_Qo7Zlt7sE40';
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(model: 'gemini-2.5-pro', apiKey: _apiKey);
  }

  Future<String> generateDiabetesInsights({
    required Map<String, dynamic> analysis,
    String selectedHorizon = '90d',
    String? recentTrends,
  }) async {
    final ra = analysis['risk_assessment'] ?? analysis;
    final horizonKey = 'horizon_${selectedHorizon}';
    final horizonRisks = (ra['horizon_risks'] ?? {}) as Map<String, dynamic>;
    final horizon = (horizonRisks[horizonKey] ?? {}) as Map<String, dynamic>;

    final gp = analysis['glucose_predictions'] as Map<String, dynamic>?;
    final forecast = <Map<String, dynamic>>[];
    if (gp != null) {
      final days = (gp['horizons_days'] as List?) ?? [];
      final p50 = (gp['p50_quantile'] as List?) ?? [];
      for (int i = 0; i < days.length && i < p50.length; i++) {
        forecast.add({'day': days[i], 'p50': p50[i]});
      }
    }

    final avgGlucose = forecast.isNotEmpty
        ? (forecast.fold<num>(0, (s, e) => s + (e['p50'] as num)) / forecast.length)
        : null;

    final context = (ra['context_factors'] ?? {}) as Map<String, dynamic>;
    final summary = {
      'selectedHorizon': selectedHorizon,
      'avgGlucose': avgGlucose == null ? null : (avgGlucose as num).round(),
      'overallRiskLevel': ra['overall_risk_level'] ?? analysis['overall_risk_level'],
      'overallRiskScore': ra['overall_risk_score'] ?? analysis['overall_risk_score'],
      'volatility': horizon['volatility_risk'],
      'hyperRisk': horizon['hyper_risk'],
      'hypoRisk': horizon['hypo_risk'],
      'contextFactors': context,
      'recentTrends': recentTrends,
    };

    final prompt = '''
You are a diabetes care specialist. Create a friendly, plain‑language report in markdown (with emojis).
Provide:
- A short summary of current risk with numbers.
- 3–5 insights explaining what's driving risk (average glucose, highs/lows, volatility).
- 5–7 day-to-day actions with checkboxes.
- Lifestyle guidance including smoking 🚭 and alcohol 🍷 always.
- A brief note for clinicians with 2–3 interventions.
- When to seek medical help.

Patient Summary:
${summary}

Rules:
- Simple language, short sections with headings, bold highlights, lists.
- 400–550 words.
''';

    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? '';
  }

  Future<String> generateDietPlan(String userName) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get user data
      final age = prefs.getString('age') ?? 'Not specified';
      final weight = prefs.getString('weight') ?? 'Not specified';
      final height = prefs.getString('height') ?? 'Not specified';
      final gender = prefs.getString('gender') ?? 'Not specified';
      final activityLevel =
          prefs.getString('activity_level') ?? 'Not specified';
      final allergies = prefs.getString('allergies') ?? 'None';
      final medications = prefs.getString('medications') ?? 'None';
      final conditions = prefs.getString('conditions') ?? 'None';
      final dietaryRestrictions =
          prefs.getStringList('dietary_restrictions') ?? [];
      final healthGoals = prefs.getStringList('health_goals') ?? [];

      // Create detailed prompt
      final prompt = '''
Create a comprehensive, personalized diet plan for $userName with the following profile:

PERSONAL INFORMATION:
- Age: $age years
- Weight: $weight kg
- Height: $height cm
- Gender: $gender
- Activity Level: $activityLevel

HEALTH INFORMATION:
- Medical Conditions: $conditions
- Current Medications: $medications
- Food Allergies/Intolerances: $allergies

DIETARY PREFERENCES:
- Restrictions: ${dietaryRestrictions.join(', ')}
- Health Goals: ${healthGoals.join(', ')}

Please provide a detailed diet plan that includes:

1. **DAILY CALORIC NEEDS**: Calculate and explain the recommended daily calories based on their profile.

2. **MACRONUTRIENT BREAKDOWN**: Provide specific percentages and grams for:
   - Carbohydrates
   - Proteins
   - Fats
   - Fiber

3. **MEAL PLAN** (7-day plan with specific meals):
   - Breakfast options (3 different options)
   - Mid-morning snack
   - Lunch options (3 different options)
   - Afternoon snack
   - Dinner options (3 different options)
   - Evening snack (if needed)

4. **SPECIFIC FOOD RECOMMENDATIONS**:
   - Best foods for their health goals
   - Foods to limit or avoid
   - Portion sizes
   - Meal timing suggestions

5. **HYDRATION GUIDELINES**: Daily water intake recommendations.

6. **SUPPLEMENTS** (if applicable): Safe, evidence-based supplement recommendations.

7. **SPECIAL CONSIDERATIONS**: Address any medical conditions, medications, or allergies.

8. **WEEKLY MEAL PREP TIPS**: Practical advice for meal preparation.

Format the response in a clear, structured manner with emojis and bullet points for easy reading. Make it encouraging and personalized for $userName.

IMPORTANT: Ensure all recommendations are safe and appropriate. Include a disclaimer to consult healthcare providers for medical conditions.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Unable to generate diet plan. Please try again.';
    } catch (e) {
      throw Exception('Failed to generate diet plan: ${e.toString()}');
    }
  }

  Future<String> generateQuickTip() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('user_name') ?? 'there';
      final healthGoals = prefs.getStringList('health_goals') ?? [];

      final prompt = '''
Generate a personalized, motivational health tip for $userName.
Their health goals are: ${healthGoals.join(', ')}.

Provide:
1. A brief, encouraging health tip (2-3 sentences)
2. One specific actionable advice
3. Keep it positive and motivating

Use their name and make it feel personal. Include relevant emojis.
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? 'Stay healthy and keep making great choices! 💪';
    } catch (e) {
      return 'Remember to stay hydrated and eat nutritious foods! 🌟';
    }
  }
}
