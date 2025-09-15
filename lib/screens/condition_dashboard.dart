import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../models/patient.dart';
import '../utils/dummy_data.dart';
import 'patient_detail_screen.dart';

class ConditionDashboard extends StatelessWidget {
  final ConditionType condition;

  const ConditionDashboard({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    final patients = DummyDataService.getPatientsForCondition(condition);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            _getConditionName(condition),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${patients.length} patients in cohort',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 16),

          // Risk Distribution Chart
          _buildRiskDistributionChart(patients),

          const SizedBox(height: 24),

          // Patient List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Patient Cohort',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              TextButton.icon(
                onPressed: () {
                  // Handle view all
                },
                icon: const Icon(Icons.filter_list, size: 18),
                label: const Text('Filter'),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Patient List
          Expanded(
            child: ListView.builder(
              itemCount: patients.length,
              itemBuilder: (context, index) {
                final patient = patients[index];
                return _buildPatientCard(context, patient);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskDistributionChart(List<Patient> patients) {
    final riskCounts = _getRiskDistribution(patients);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Risk Distribution',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // Pie Chart
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: riskCounts[RiskLevel.low]?.toDouble() ?? 0,
                            title: 'Low\n${riskCounts[RiskLevel.low] ?? 0}',
                            color: AppColors.lowRisk,
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value:
                                riskCounts[RiskLevel.medium]?.toDouble() ?? 0,
                            title:
                                'Medium\n${riskCounts[RiskLevel.medium] ?? 0}',
                            color: AppColors.mediumRisk,
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: riskCounts[RiskLevel.high]?.toDouble() ?? 0,
                            title: 'High\n${riskCounts[RiskLevel.high] ?? 0}',
                            color: AppColors.highRiskColor,
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),

                  // Legend
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendItem('Low Risk', AppColors.lowRisk),
                        const SizedBox(height: 8),
                        _buildLegendItem('Medium Risk', AppColors.mediumRisk),
                        const SizedBox(height: 8),
                        _buildLegendItem('High Risk', AppColors.highRiskColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildPatientCard(BuildContext context, Patient patient) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getRiskColor(
            patient.riskLevel,
          ).withValues(alpha: 0.2),
          child: Icon(Icons.person, color: _getRiskColor(patient.riskLevel)),
        ),
        title: Text(
          patient.name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Age: ${patient.age} years'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getRiskColor(
                      patient.riskLevel,
                    ).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    patient.riskLevelText,
                    style: TextStyle(
                      color: _getRiskColor(patient.riskLevel),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${patient.riskScore.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: _getRiskColor(patient.riskLevel),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PatientDetailScreen(patient: patient),
            ),
          );
        },
      ),
    );
  }

  Color _getRiskColor(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return AppColors.lowRisk;
      case RiskLevel.medium:
        return AppColors.mediumRisk;
      case RiskLevel.high:
        return AppColors.highRiskColor;
    }
  }

  Map<RiskLevel, int> _getRiskDistribution(List<Patient> patients) {
    final Map<RiskLevel, int> distribution = {};

    for (final patient in patients) {
      distribution[patient.riskLevel] =
          (distribution[patient.riskLevel] ?? 0) + 1;
    }

    return distribution;
  }

  String _getConditionName(ConditionType condition) {
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
