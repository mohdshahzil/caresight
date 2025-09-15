import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../constants/app_colors.dart';
import '../models/diabetes_models.dart';
import 'diabetes_insights_screen.dart';

class DiabetesReportScreen extends StatelessWidget {
  final ParsedDiabetesData parsed;
  final Map<String, dynamic> rawResponse;
  final Map<String, dynamic> payload;
  const DiabetesReportScreen({super.key, required this.parsed, required this.rawResponse, required this.payload});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diabetes Report'),
        actions: [
          IconButton(
            tooltip: 'AI Insights',
            icon: const Icon(Icons.psychology_alt_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DiabetesInsightsScreen(
                    analysis: rawResponse,
                    selectedHorizon: '90d',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () async {
              final jsonStr = const JsonEncoder.withIndent('  ').convert(rawResponse);
              await Share.share(jsonStr, subject: 'Diabetes Analysis JSON');
            },
          ),
          IconButton(
            icon: const Icon(Icons.cloud_download_outlined),
            onPressed: () async {
              final jsonStr = const JsonEncoder.withIndent('  ').convert(payload);
              await Share.share(jsonStr, subject: 'Diabetes Payload JSON');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _overallRiskCard(parsed.overallRisk),
                const SizedBox(height: 12),
                _glucoseForecastChart(parsed.forecastData),
                const SizedBox(height: 12),
                _horizonRiskChart(parsed.horizonRiskData),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _overallRiskCard(OverallRiskSummary risk) {
    final percent = (risk.score * 100).toStringAsFixed(0);
    final color = risk.level.toLowerCase() == 'high'
        ? Colors.red.shade400
        : risk.level.toLowerCase() == 'low'
            ? Colors.green.shade400
            : Colors.amber.shade400;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Overall 90-Day Risk', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 12),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                  child: Text('$percent%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(12)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(risk.level[0].toUpperCase() + risk.level.substring(1),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color.darken())),
                      const SizedBox(height: 4),
                      const Text('Current Status'),
                    ]),
                  ),
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _glucoseForecastChart(List<GlucoseForecastPoint> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    List<FlSpot> s10 = [], s50 = [], s90 = [];
    for (final p in data) {
      s10.add(FlSpot(p.day.toDouble(), p.p10));
      s50.add(FlSpot(p.day.toDouble(), p.p50));
      s90.add(FlSpot(p.day.toDouble(), p.p90));
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Your Glucose Levels – Next 90 Days', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: const FlTitlesData(show: true),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12)),
              lineBarsData: [
                LineChartBarData(spots: s10, isCurved: true, color: Colors.blue.shade200, barWidth: 2),
                LineChartBarData(spots: s50, isCurved: true, color: Colors.blue.shade600, barWidth: 3),
                LineChartBarData(spots: s90, isCurved: true, color: Colors.blue.shade900, barWidth: 2),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _horizonRiskChart(List<HorizonRiskPoint> data) {
    if (data.isEmpty) return const SizedBox.shrink();
    final bars = <BarChartGroupData>[];
    for (int i = 0; i < data.length; i++) {
      bars.add(BarChartGroupData(x: i, barRods: [BarChartRodData(toY: data[i].riskScore, color: AppColors.primaryGreen)]));
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Your Health Risk Over Time', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(show: true),
              barGroups: bars,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                    final idx = v.toInt();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(idx >= 0 && idx < data.length ? data[idx].label : ''),
                    );
                  }),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

extension _ColorDarken on Color {
  Color darken([double amount = .2]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}


