import '../models/patient.dart';
import '../models/evaluation_metrics.dart';

class DummyDataService {
  static List<Patient> getPatientsForCondition(ConditionType condition) {
    switch (condition) {
      case ConditionType.cardiovascular:
        return _getCardiovascularPatients();
      case ConditionType.diabetes:
        return _getDiabetesPatients();
      case ConditionType.arthritis:
        return _getArthritisPatients();
    }
  }

  static List<Patient> _getCardiovascularPatients() {
    return [
      Patient(
        id: '4',
        name: 'Robert Smith',
        age: 55,
        riskScore: 25.3,
        riskLevel: RiskLevel.low,
        condition: ConditionType.cardiovascular,
        vitals: _generateVitals('HR', 'bpm', 72, 75),
        riskDrivers: [
          RiskDriver(
            name: 'Cholesterol Levels',
            importance: 0.30,
            description: 'Well-controlled cholesterol',
          ),
          RiskDriver(
            name: 'Blood Pressure',
            importance: 0.25,
            description: 'Normal blood pressure range',
          ),
          RiskDriver(
            name: 'Exercise Routine',
            importance: 0.20,
            description: 'Regular physical activity',
          ),
        ],
        recommendedActions: [
          'Continue current medication regimen',
          'Maintain regular exercise routine',
          'Annual cardiovascular screening',
        ],
      ),
      Patient(
        id: '5',
        name: 'Michael Brown',
        age: 68,
        riskScore: 65.7,
        riskLevel: RiskLevel.high,
        condition: ConditionType.cardiovascular,
        vitals: _generateVitals('HR', 'bpm', 95, 100),
        riskDrivers: [
          RiskDriver(
            name: 'Previous MI',
            importance: 0.40,
            description: 'History of myocardial infarction',
          ),
          RiskDriver(
            name: 'Diabetes',
            importance: 0.30,
            description: 'Type 2 diabetes comorbidity',
          ),
          RiskDriver(
            name: 'Smoking History',
            importance: 0.20,
            description: 'Previous smoking history',
          ),
        ],
        recommendedActions: [
          'Intensive medication management',
          'Cardiac rehabilitation program',
          'Monthly cardiology follow-up',
          'Lifestyle modification counseling',
        ],
      ),
    ];
  }

  static List<Patient> _getDiabetesPatients() {
    return [
      Patient(
        id: '6',
        name: 'Emily Davis',
        age: 45,
        riskScore: 35.2,
        riskLevel: RiskLevel.medium,
        condition: ConditionType.diabetes,
        vitals: _generateVitals('Glucose', 'mg/dL', 180, 200),
        riskDrivers: [
          RiskDriver(
            name: 'HbA1c Levels',
            importance: 0.35,
            description: 'Elevated HbA1c indicating poor control',
          ),
          RiskDriver(
            name: 'Weight Management',
            importance: 0.25,
            description: 'BMI above target range',
          ),
          RiskDriver(
            name: 'Medication Adherence',
            importance: 0.20,
            description: 'Inconsistent medication compliance',
          ),
        ],
        recommendedActions: [
          'Adjust medication dosage',
          'Nutritional counseling',
          'Blood glucose monitoring training',
        ],
      ),
      Patient(
        id: '7',
        name: 'David Wilson',
        age: 52,
        riskScore: 82.1,
        riskLevel: RiskLevel.high,
        condition: ConditionType.diabetes,
        vitals: _generateVitals('Glucose', 'mg/dL', 250, 300),
        riskDrivers: [
          RiskDriver(
            name: 'Severe Hyperglycemia',
            importance: 0.45,
            description: 'Dangerously high blood glucose levels',
          ),
          RiskDriver(
            name: 'Kidney Function',
            importance: 0.30,
            description: 'Declining kidney function',
          ),
          RiskDriver(
            name: 'Multiple Complications',
            importance: 0.20,
            description: 'Presence of multiple diabetic complications',
          ),
        ],
        recommendedActions: [
          'Immediate medical intervention',
          'Consider insulin therapy adjustment',
          'Nephrology consultation',
          'Emergency contact information provided',
        ],
      ),
    ];
  }

  static List<Patient> _getArthritisPatients() {
    return [
      Patient(
        id: '8',
        name: 'Linda Anderson',
        age: 62,
        riskScore: 28.7,
        riskLevel: RiskLevel.low,
        condition: ConditionType.arthritis,
        vitals: _generateVitals('Pain', 'scale', 3, 4),
        riskDrivers: [
          RiskDriver(
            name: 'Joint Function',
            importance: 0.30,
            description: 'Good joint mobility maintained',
          ),
          RiskDriver(
            name: 'Inflammation Markers',
            importance: 0.25,
            description: 'Low inflammatory markers',
          ),
          RiskDriver(
            name: 'Physical Activity',
            importance: 0.20,
            description: 'Regular low-impact exercise',
          ),
        ],
        recommendedActions: [
          'Continue current treatment plan',
          'Maintain physical therapy routine',
          'Regular monitoring of joint function',
        ],
      ),
      Patient(
        id: '9',
        name: 'James Taylor',
        age: 58,
        riskScore: 71.4,
        riskLevel: RiskLevel.high,
        condition: ConditionType.arthritis,
        vitals: _generateVitals('Pain', 'scale', 8, 9),
        riskDrivers: [
          RiskDriver(
            name: 'Severe Joint Damage',
            importance: 0.40,
            description: 'Significant joint deterioration',
          ),
          RiskDriver(
            name: 'High Inflammation',
            importance: 0.30,
            description: 'Elevated inflammatory markers',
          ),
          RiskDriver(
            name: 'Limited Mobility',
            importance: 0.20,
            description: 'Severely restricted joint movement',
          ),
        ],
        recommendedActions: [
          'Consider surgical intervention',
          'Pain management specialist referral',
          'Physical therapy intensification',
          'Assistive device evaluation',
        ],
      ),
    ];
  }

  static List<VitalReading> _generateVitals(
    String type,
    String unit,
    double min,
    double max,
  ) {
    final now = DateTime.now();
    return List.generate(30, (index) {
      final date = now.subtract(Duration(days: 29 - index));
      final value = min + (max - min) * (0.8 + 0.4 * (index / 29));
      return VitalReading(
        date: date,
        vitalType: type,
        value: value,
        unit: unit,
      );
    });
  }

  static EvaluationMetrics getEvaluationMetrics() {
    return EvaluationMetrics(
      auroc: 0.87,
      auprc: 0.82,
      calibrationScore: 0.91,
      confusionMatrix: ConfusionMatrix(
        truePositives: 145,
        falsePositives: 23,
        trueNegatives: 312,
        falseNegatives: 18,
      ),
    );
  }

  static List<FeatureImportance> getGlobalFeatureImportance() {
    return [
      FeatureImportance(
        featureName: 'Age',
        importance: 0.25,
        description: 'Patient age is a significant risk factor',
      ),
      FeatureImportance(
        featureName: 'Blood Pressure',
        importance: 0.20,
        description: 'Hypertension increases risk',
      ),
      FeatureImportance(
        featureName: 'BMI',
        importance: 0.15,
        description: 'Body mass index correlation',
      ),
      FeatureImportance(
        featureName: 'Lab Values',
        importance: 0.18,
        description: 'Laboratory test results',
      ),
      FeatureImportance(
        featureName: 'Medication History',
        importance: 0.12,
        description: 'Previous medication use',
      ),
      FeatureImportance(
        featureName: 'Family History',
        importance: 0.10,
        description: 'Genetic predisposition factors',
      ),
    ];
  }
}
