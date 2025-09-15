import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import '../constants/app_colors.dart';
import '../services/diabetes_service.dart';
import 'diabetes_report_screen.dart';
import '../utils/logging.dart';

class DiabetesUploadScreen extends StatefulWidget {
  const DiabetesUploadScreen({super.key});

  @override
  State<DiabetesUploadScreen> createState() => _DiabetesUploadScreenState();
}

class _DiabetesUploadScreenState extends State<DiabetesUploadScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  String _gender = '';
  final _weight = TextEditingController();
  final _height = TextEditingController();
  PlatformFile? _file;

  String _stage = 'idle';
  String? _error;
  bool _loaded = false;
  String? _sampleCsvText;
  Map<String, String>? _sampleOverview;

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadDemographicsFromPrefs();
    _loadSampleCsv();
  }

  Future<void> _loadDemographicsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name') ?? '';
      final ageStr = prefs.getString('age') ?? '';
      final gender = prefs.getString('gender') ?? '';
      final weightStr = prefs.getString('weight') ?? '';
      final heightStr = prefs.getString('height') ?? '';

      setState(() {
        _name.text = name;
        _age.text = ageStr;
        _gender = gender;
        _weight.text = weightStr;
        _height.text = heightStr;
        _loaded = true;
      });
    } catch (_) {
      setState(() => _loaded = true);
    }
  }

  Future<void> _loadSampleCsv() async {
    try {
      final text = await rootBundle.loadString('test_data_diab.csv');
      setState(() => _sampleCsvText = text);
      _computeOverview(text);
    } catch (_) {}
  }

  void _computeOverview(String text) {
    try {
      final lines = text.trim().split(RegExp(r'\r?\n'));
      if (lines.length < 2) return;
      final rows = lines.skip(1).where((l) => l.trim().isNotEmpty).toList();
      if (rows.isEmpty) return;
      final first = rows.first.split(',');
      final last = rows.last.split(',');
      const dateIdx = 1;
      const gMeanIdx = 2;
      final start = first.length > dateIdx ? first[dateIdx] : '';
      final end = last.length > dateIdx ? last[dateIdx] : '';
      double sum = 0;
      int count = 0;
      for (final r in rows) {
        final parts = r.split(',');
        if (parts.length > gMeanIdx) {
          final v = double.tryParse(parts[gMeanIdx]);
          if (v != null) {
            sum += v;
            count++;
          }
        }
      }
      final avg = count > 0 ? (sum / count) : 0;
      setState(() {
        _sampleOverview = {
          'Rows': '$count',
          'Date Range': '$start → $end',
          'Avg g_mean': avg.toStringAsFixed(1),
        };
      });
    } catch (_) {}
  }

  Future<void> _pickCsv() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv'], withData: true);
    if (result != null && result.files.isNotEmpty) {
      setState(() => _file = result.files.first);
    }
  }

  Future<void> _startAnalysis() async {
    // Use bundled sample if user hasn't picked a file
    if (_file == null && _sampleCsvText == null) {
      setState(() => _error = 'Sample CSV not found. Please select a CSV.');
      return;
    }
    setState(() {
      _error = null;
      _stage = 'building-payload';
    });

    try {
      final payload = _file != null
          ? await DiabetesCsvPayloadBuilder.buildFromCsv(
              file: _file!,
              name: (_name.text.trim().isEmpty ? 'patient' : _name.text.trim()),
              age: int.tryParse(_age.text) ?? 0,
              gender: _gender.isEmpty ? 'other' : _gender,
              weight: double.tryParse(_weight.text),
              height: double.tryParse(_height.text),
            )
          : await _buildPayloadFromSample();

      setState(() => _stage = 'calling-api');

      final api = DiabetesApiClient('http://172.16.44.133:10000/api/glucose');
      logDebug('Calling API with payload', {'patients': payload.toJson()['patients']?.length});
      final resp = await api.predict(payload);

      setState(() => _stage = 'parsing-response');
      final parsed = DiabetesResponseParser.parse(resp);
      logDebug('Parsed for UI', {
        'forecast_len': parsed.forecastData.length,
        'horizon_len': parsed.horizonRiskData.length,
        'overall': parsed.overallRisk.score
      });

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DiabetesReportScreen(
            parsed: parsed,
            rawResponse: resp,
            payload: payload.toJson(),
          ),
        ),
      );
      setState(() => _stage = 'complete');
    } catch (e) {
      setState(() {
        _stage = 'error';
        _error = e.toString();
      });
    }
  }

  Future _buildPayloadFromSample() async {
    final bytes = Uint8List.fromList((_sampleCsvText ?? '').codeUnits);
    final file = PlatformFile(name: 'test_data_diab.csv', size: bytes.length, bytes: bytes);
    return DiabetesCsvPayloadBuilder.buildFromCsv(
      file: file,
      name: (_name.text.trim().isEmpty ? 'patient' : _name.text.trim()),
      age: int.tryParse(_age.text) ?? 0,
      gender: _gender.isEmpty ? 'other' : _gender,
      weight: double.tryParse(_weight.text),
      height: double.tryParse(_height.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diabetes Risk Assessment')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _sectionTitle('Patient Information'),
                _patientSummaryCard(),

                const SizedBox(height: 20),
                _sectionTitle('Glucose CSV'),
                OutlinedButton.icon(
                  onPressed: _pickCsv,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_file == null ? 'Select CSV' : 'Selected: ${_file!.name}'),
                ),

                if (_sampleOverview != null) ...[
                  const SizedBox(height: 12),
                  _datasetOverviewCard(_sampleOverview!),
                ],

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _stage == 'calling-api' ? null : _startAnalysis,
                  child: const Text('Run Analysis'),
                ),

                if (_stage != 'idle') ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      _stage == 'error'
                          ? 'Error'
                          : _stage.replaceAll('-', ' ').toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
    );
  }

  // Unused legacy form builders removed since demographics are pre-filled

  Widget _patientSummaryCard() {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.person, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Text(_name.text.isEmpty ? 'Unknown' : _name.text, style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _pill('Age', _age.text.isEmpty ? '—' : _age.text),
          _pill('Gender', _gender.isEmpty ? '—' : _gender),
          _pill('Weight', _weight.text.isEmpty ? '—' : '${_weight.text} kg'),
          _pill('Height', _height.text.isEmpty ? '—' : '${_height.text} cm'),
        ]),
        const SizedBox(height: 8),
        Text('Edit in profile if incorrect (Drawer → Dashboard → Profile).', style: TextStyle(color: Colors.black.withValues(alpha: 0.6))),
      ]),
    );
  }

  Widget _pill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.textLight.withValues(alpha: 0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value),
      ]),
    );
  }

  Widget _datasetOverviewCard(Map<String, String> stats) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.assessment, color: AppColors.primaryGreen),
          SizedBox(width: 8),
          Text('Sample Dataset Overview', style: TextStyle(fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        Wrap(spacing: 12, runSpacing: 8, children: [
          _pill('Rows', stats['Rows'] ?? '—'),
          _pill('Date Range', stats['Date Range'] ?? '—'),
          _pill('Avg g_mean', stats['Avg g_mean'] ?? '—'),
        ]),
        const SizedBox(height: 8),
        const Text('You can run analysis using this bundled sample or pick your own CSV.'),
      ]),
    );
  }
}


