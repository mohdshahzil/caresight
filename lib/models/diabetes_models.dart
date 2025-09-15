import 'dart:convert';

class DiabetesPayloadPatientRecord {
  final Map<String, dynamic> data;
  DiabetesPayloadPatientRecord(this.data);
}

class DiabetesPayloadPatient {
  final dynamic patientId;
  final String name;
  final int age;
  final String gender;
  final double? weight;
  final double? height;
  final String analysisTimestamp;
  final List<DiabetesPayloadPatientRecord> data;
  final Map<String, dynamic> contexts;
  final List<int> riskHorizons;

  DiabetesPayloadPatient({
    required this.patientId,
    required this.name,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.analysisTimestamp,
    required this.data,
    required this.contexts,
    required this.riskHorizons,
  });

  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
        'name': name,
        'age': age,
        'gender': gender,
        'weight': weight,
        'height': height,
        'analysis_timestamp': analysisTimestamp,
        'data': data.map((e) => e.data).toList(),
        'contexts': contexts,
        'risk_horizons': riskHorizons,
      };
}

class DiabetesPayload {
  final List<DiabetesPayloadPatient> patients;
  DiabetesPayload(this.patients);

  Map<String, dynamic> toJson() => {
        'patients': patients.map((p) => p.toJson()).toList(),
      };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}

class GlucoseForecastPoint {
  final int day;
  final double p10;
  final double p50;
  final double p90;
  GlucoseForecastPoint({required this.day, required this.p10, required this.p50, required this.p90});
}

class HorizonRiskPoint {
  final String label;
  final double riskScore;
  HorizonRiskPoint({required this.label, required this.riskScore});
}

class OverallRiskSummary {
  final double score; // 0..1
  final String level; // low/moderate/high
  OverallRiskSummary({required this.score, required this.level});
}

class ParsedDiabetesData {
  final OverallRiskSummary overallRisk;
  final List<GlucoseForecastPoint> forecastData;
  final List<HorizonRiskPoint> horizonRiskData;
  ParsedDiabetesData({
    required this.overallRisk,
    required this.forecastData,
    required this.horizonRiskData,
  });
}

// Class-style model similar to the web implementation
class DiabetesPrediction {
  final dynamic patientId;
  final Map<String, dynamic>? predictionMetadata;
  final Map<String, dynamic>? glucosePredictions;
  final Map<String, dynamic>? modelInfo;
  final Map<String, dynamic>? riskAssessment;
  final Map<String, dynamic> raw;

  DiabetesPrediction({
    required this.patientId,
    required this.predictionMetadata,
    required this.glucosePredictions,
    required this.modelInfo,
    required this.riskAssessment,
    required this.raw,
  });

  static DiabetesPrediction? fromAny(Map<String, dynamic> response) {
    final root = _extractRootDeep(response) ?? response;
    final ra = (root['risk_assessment'] as Map<String, dynamic>?) ?? {};
    final pred = root['glucose_predictions'] as Map<String, dynamic>?;
    return DiabetesPrediction(
      patientId: root['patient_id'] ?? (root['prediction_metadata'] is Map ? root['prediction_metadata']['patient_id'] : null),
      predictionMetadata: root['prediction_metadata'] as Map<String, dynamic>?,
      glucosePredictions: pred,
      modelInfo: root['model_info'] as Map<String, dynamic>?,
      riskAssessment: ra.isEmpty ? null : ra,
      raw: root,
    );
  }

  List<GlucoseForecastPoint> getForecastData() {
    final gp = glucosePredictions ?? {};
    final horizonsDyn = (gp['horizons_days'] as List?) ?? const [];
    final horizons = horizonsDyn.map((e) => _asNum(e)?.toInt()).whereType<int>().toList();
    final p10 = _asNumList(gp['p10_quantile']);
    final p50 = _asNumList(gp['p50_quantile']);
    final p90 = _asNumList(gp['p90_quantile']);
    final List<GlucoseForecastPoint> out = [];
    for (int i = 0; i < horizons.length && i < p10.length && i < p50.length && i < p90.length; i++) {
      out.add(GlucoseForecastPoint(day: horizons[i], p10: p10[i].toDouble(), p50: p50[i].toDouble(), p90: p90[i].toDouble()));
    }
    return out;
  }

  ParsedDiabetesData toParsedData() {
    final ra = riskAssessment ?? {};
    final overallScore = (_asNum(raw['overall_risk_score']) ?? _asNum(ra['overall_risk_score']) ?? 0).toDouble();
    final overallLevel = (raw['overall_risk_level'] ?? ra['overall_risk_level'] ?? 'moderate').toString();

    final hr = (ra['horizon_risks'] as Map<String, dynamic>?) ?? {};
    final labels = <String>['horizon_7d', 'horizon_14d', 'horizon_30d', 'horizon_60d', 'horizon_90d'];
    final List<HorizonRiskPoint> horizonPoints = [];
    for (final key in labels) {
      final obj = hr[key] as Map<String, dynamic>?;
      if (obj == null) continue;
      horizonPoints.add(HorizonRiskPoint(
        label: key.replaceAll('horizon_', ''),
        riskScore: (_asNum(obj['risk_score']) ?? 0).toDouble(),
      ));
    }

    return ParsedDiabetesData(
      overallRisk: OverallRiskSummary(score: overallScore, level: overallLevel),
      forecastData: getForecastData(),
      horizonRiskData: horizonPoints,
    );
  }
}

// Helpers
num? _asNum(dynamic v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v);
  return null;
}

List<num> _asNumList(dynamic v) {
  if (v is List) {
    return v.map((e) => _asNum(e)).whereType<num>().toList();
  }
  return <num>[];
}

Map<String, dynamic>? _extractRootDeep(dynamic node) {
  if (node is Map<String, dynamic>) {
    if (node.containsKey('glucose_predictions') || node.containsKey('risk_assessment')) {
      return node;
    }
    for (final entry in node.entries) {
      final found = _extractRootDeep(entry.value);
      if (found != null) return found;
    }
  } else if (node is List) {
    for (final el in node) {
      final found = _extractRootDeep(el);
      if (found != null) return found;
    }
  }
  return null;
}

