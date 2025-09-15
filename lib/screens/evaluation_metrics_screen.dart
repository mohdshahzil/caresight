import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/evaluation_metrics.dart';
import '../utils/dummy_data.dart';

class EvaluationMetricsScreen extends StatelessWidget {
  const EvaluationMetricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = DummyDataService.getEvaluationMetrics();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Model Evaluation Metrics',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Performance metrics for the AI risk prediction model',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 24),

            // Metrics Cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildMetricCard(
                    'AUROC',
                    metrics.auroc.toStringAsFixed(3),
                    'Area Under ROC Curve',
                    AppColors.primaryGreen,
                    Icons.trending_up,
                  ),
                  _buildMetricCard(
                    'AUPRC',
                    metrics.auprc.toStringAsFixed(3),
                    'Area Under PR Curve',
                    AppColors.primaryBlue,
                    Icons.analytics,
                  ),
                  _buildMetricCard(
                    'Calibration',
                    metrics.calibrationScore.toStringAsFixed(3),
                    'Calibration Score',
                    AppColors.lightGreen,
                    Icons.balance,
                  ),
                  _buildMetricCard(
                    'Accuracy',
                    metrics.confusionMatrix.accuracy.toStringAsFixed(3),
                    'Overall Accuracy',
                    AppColors.accentGreen,
                    Icons.check_circle,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Confusion Matrix
            _buildConfusionMatrix(metrics.confusionMatrix),

            const SizedBox(height: 16),

            // Additional Metrics
            _buildAdditionalMetrics(metrics.confusionMatrix),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String description,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfusionMatrix(ConfusionMatrix matrix) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confusion Matrix',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: Table(
                border: TableBorder.all(color: AppColors.textLight),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    ),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Predicted\nPositive',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Predicted\nNegative',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Actual\nPositive',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          color: AppColors.lightGreen.withValues(alpha: 0.3),
                          child: Text(
                            matrix.truePositives.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          color: AppColors.riskOrange.withValues(alpha: 0.3),
                          child: Text(
                            matrix.falseNegatives.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Actual\nNegative',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          color: AppColors.riskOrange.withValues(alpha: 0.3),
                          child: Text(
                            matrix.falsePositives.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          color: AppColors.lightGreen.withValues(alpha: 0.3),
                          child: Text(
                            matrix.trueNegatives.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalMetrics(ConfusionMatrix matrix) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Additional Performance Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Precision',
                    matrix.precision.toStringAsFixed(3),
                    AppColors.primaryBlue,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Recall',
                    matrix.recall.toStringAsFixed(3),
                    AppColors.primaryGreen,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'F1-Score',
                    matrix.f1Score.toStringAsFixed(3),
                    AppColors.riskOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
