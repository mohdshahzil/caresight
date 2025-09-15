import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../models/diabetes_models.dart';
import '../utils/logging.dart';

class DiabetesCsvPayloadBuilder {
  static Future<DiabetesPayload> buildFromCsv({
    required PlatformFile file,
    required String name,
    required int age,
    required String gender,
    double? weight,
    double? height,
  }) async {
    final content = String.fromCharCodes(file.bytes ?? await file.readStream!.fold<List<int>>(<int>[], (prev, el) => prev..addAll(el)));
    final lines = content.trim().split(RegExp(r'\r?\n'));
    if (lines.length < 2) {
      throw Exception('CSV must contain header and at least one row');
    }
    final headers = lines.first.split(',').map((e) => e.trim()).toList();
    logDebug('CSV headers parsed', {'headers': headers});
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    int rowIdx = 0;
    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;
      final cells = line.split(',').map((e) => e.trim()).toList();
      rowIdx++;
      final record = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        final h = headers[i];
        final v = i < cells.length ? cells[i] : '';
        if (v.isEmpty) {
          record[h] = null;
        } else if (double.tryParse(v) != null) {
          record[h] = double.parse(v);
        } else if (v.toLowerCase() == 'true' || v == '1') {
          record[h] = 1;
        } else if (v.toLowerCase() == 'false' || v == '0') {
          record[h] = 0;
        } else {
          record[h] = v;
        }
      }

      // Ensure patient_id is an integer if numeric to avoid 0.0 issues
      if (record.containsKey('patient_id') && record['patient_id'] is num) {
        record['patient_id'] = (record['patient_id'] as num).toInt();
      }

      final pidValue = record['patient_id'] ?? name;
      final pid = pidValue.toString();

      // Normalize fields similar to web
      record['missed_insulin'] = _norm01(record['missed_insulin']);
      record['exercise_flag'] = _norm01(record['exercise_flag']);
      record['illness_flag'] = _norm01(record['illness_flag']);
      record['is_weekend'] = _norm01(record['is_weekend']);
      record['pct_hypo'] = _percent(record['pct_hypo']);
      record['pct_hyper'] = _percent(record['pct_hyper']);

      grouped.putIfAbsent(pid, () => <Map<String, dynamic>>[]).add(record);
      if (rowIdx <= 3) {
        logDebug('CSV row parsed', {'row': rowIdx, 'patient_id': pid, 'record_sample': record});
      }
    }

    final riskHorizons = <int>[7, 14, 30, 60, 90];
    final patients = grouped.entries.map((e) {
      final rows = e.value;
      // Sort by date ascending if date present
      rows.sort((a, b) {
        final da = DateTime.tryParse((a['date'] ?? '').toString());
        final db = DateTime.tryParse((b['date'] ?? '').toString());
        if (da == null || db == null) return 0;
        return da.compareTo(db);
      });
      final last = rows.isNotEmpty ? rows.last : <String, dynamic>{};
      final dynamic firstPid = rows.isNotEmpty ? rows.first['patient_id'] : e.key;
      final dynamic patientId = (firstPid is num) ? firstPid.toInt() : firstPid;
      return DiabetesPayloadPatient(
        patientId: patientId,
        name: name,
        age: age,
        gender: gender,
        weight: weight,
        height: height,
        analysisTimestamp: DateTime.now().toIso8601String(),
        data: rows.map((r) => DiabetesPayloadPatientRecord(r)).toList(),
        contexts: {
          'insulin_adherence': (last['insulin_adherence'] ?? 1) as num,
          'sleep_quality': (last['sleep_quality'] ?? 0.8) as num,
          'insulin_dose': (last['insulin_dose'] ?? 30) as num,
        },
        riskHorizons: riskHorizons,
      );
    }).toList();

    final payload = DiabetesPayload(patients);
    logDebug('Payload built', {'patients': payload.toJson()['patients']?.length});
    return payload;
  }

  static int _norm01(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v > 0 ? 1 : 0;
    final s = v.toString().toLowerCase();
    return (s == '1' || s == 'true') ? 1 : 0;
  }

  static num _percent(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v <= 1 ? v * 100 : v;
    final d = double.tryParse(v.toString());
    if (d == null) return 0;
    return d <= 1 ? d * 100 : d;
  }
}

class DiabetesApiClient {
  final String baseUrl;
  DiabetesApiClient(this.baseUrl);

  Future<Map<String, dynamic>> predict(DiabetesPayload payload) async {
    final isCohort = payload.patients.length > 1;
    final url = Uri.parse(isCohort ? '$baseUrl/cohort' : baseUrl);
    final body = jsonEncode(isCohort ? payload.toJson() : payload.patients.first.toJson());
    logDebug('POST', {
      'url': url.toString(),
      'isCohort': isCohort,
      'patients_len': payload.patients.length,
      'first_rows': payload.patients.first.data.length,
      'size': body.length
    });
    final resp = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);
    logDebug('API response meta', {'status': resp.statusCode, 'len': resp.body.length});
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('API Error ${resp.statusCode}: ${resp.body}');
    }
    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    logDebug('API response keys', {'keys': decoded.keys.toList()});
    return decoded;
  }
}

class DiabetesResponseParser {
  static ParsedDiabetesData parse(Map<String, dynamic> json) {
    // Build via class-style model to mirror web
    logDebug('Parsing diabetes response', {'keys': json.keys.toList()});
    final prediction = DiabetesPrediction.fromAny(json);
    if (prediction == null) {
      return ParsedDiabetesData(
        overallRisk: OverallRiskSummary(score: 0, level: 'unknown'),
        forecastData: const [],
        horizonRiskData: const [],
      );
    }
    final parsed = prediction.toParsedData();
    logDebug('Parsed result sizes', {
      'forecast_len': parsed.forecastData.length,
      'horizon_len': parsed.horizonRiskData.length,
      'overall': parsed.overallRisk.score
    });
    return parsed;
  }

  static Map<String, dynamic> _extractRoot(Map<String, dynamic> json) {
    // If glucose_predictions present at root, return root
    if (json.containsKey('glucose_predictions') || json.containsKey('risk_assessment')) {
      return json;
    }
    // Try common wrappers
    for (final key in ['patients', 'results', 'data']) {
      final v = json[key];
      if (v is List && v.isNotEmpty && v.first is Map<String, dynamic>) {
        final first = v.first as Map<String, dynamic>;
        if (first.containsKey('glucose_predictions') || first.containsKey('risk_assessment')) {
          return first;
        }
      }
    }
    return json;
  }

  static Map<String, dynamic>? _extractRootDeep(dynamic node) {
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

  static num? _asNum(dynamic v) {
    if (v is num) return v;
    if (v is String) return num.tryParse(v);
    return null;
  }

  static List<num> _asNumList(dynamic v) {
    if (v is List) {
      return v.map((e) => _asNum(e)).whereType<num>().toList();
    }
    return <num>[];
  }
}


