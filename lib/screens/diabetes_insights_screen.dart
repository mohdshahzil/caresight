import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../constants/app_colors.dart';
import '../services/gemini_service.dart';
import '../utils/logging.dart';

class DiabetesInsightsScreen extends StatefulWidget {
  final Map<String, dynamic> analysis;
  final String selectedHorizon;
  const DiabetesInsightsScreen({super.key, required this.analysis, this.selectedHorizon = '90d'});

  @override
  State<DiabetesInsightsScreen> createState() => _DiabetesInsightsScreenState();
}

class _DiabetesInsightsScreenState extends State<DiabetesInsightsScreen> {
  String? _markdown;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final gemini = GeminiService();
      logDebug('Generating AI insights', {'horizon': widget.selectedHorizon});
      final md = await gemini.generateDiabetesInsights(
        analysis: widget.analysis,
        selectedHorizon: widget.selectedHorizon,
      );
      if (!mounted) return;
      setState(() => _markdown = md.isEmpty ? '# No insights generated' : md);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Insights')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.redAccent)))
              : _markdown == null
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : Markdown(
                      data: _markdown!,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                        p: const TextStyle(color: Colors.white),
                        h1: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        h2: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        h3: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        listBullet: const TextStyle(color: Colors.white),
                      ),
                    ),
        ),
      ),
    );
  }
}


