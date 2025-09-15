enum RiskLevel { low, medium, high }

enum ConditionType { maternalCare, cardiovascular, diabetes, arthritis }

class Patient {
  final String id;
  final String name;
  final int age;
  final double riskScore;
  final RiskLevel riskLevel;
  final ConditionType condition;
  final List<VitalReading> vitals;
  final List<RiskDriver> riskDrivers;
  final List<String> recommendedActions;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.riskScore,
    required this.riskLevel,
    required this.condition,
    required this.vitals,
    required this.riskDrivers,
    required this.recommendedActions,
  });

  String get riskLevelText {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
    }
  }

  String get conditionText {
    switch (condition) {
      case ConditionType.maternalCare:
        return 'Maternal Care';
      case ConditionType.cardiovascular:
        return 'Cardiovascular';
      case ConditionType.diabetes:
        return 'Diabetes';
      case ConditionType.arthritis:
        return 'Arthritis';
    }
  }
}

class VitalReading {
  final DateTime date;
  final String vitalType;
  final double value;
  final String unit;

  VitalReading({
    required this.date,
    required this.vitalType,
    required this.value,
    required this.unit,
  });
}

class RiskDriver {
  final String name;
  final double importance;
  final String description;

  RiskDriver({
    required this.name,
    required this.importance,
    required this.description,
  });
}
