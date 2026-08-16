import 'dart:math';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import '../models/trace_db.dart';
import 'health_thresholds.dart';

class RawHealthRecord {
  final DateTime timestamp;
  final String parameter;
  final double value;

  RawHealthRecord({
    required this.timestamp,
    required this.parameter,
    required this.value,
  });

  factory RawHealthRecord.fromJson(Map<String, dynamic> json) {
    return RawHealthRecord(
      timestamp: DateTime.parse(json['timestamp'] as String),
      parameter: json['parameter'] as String,
      value: (json['value'] as num).toDouble(),
    );
  }
}

class HealthDataPoint {
  final DateTime timestamp;

  double? hr;
  double? bpSyst;
  double? bpDiast;
  double? spo2;
  double? temp;
  double? bloodSugar;
  double? hrv;
  double? stress;

  HealthDataPoint({required this.timestamp});

  void addValue(String param, double rawValue) {
    final parsed = rawValue;
    final p = param.toLowerCase().trim();
    _setSingleValue(p, parsed);
  }

  void _setSingleValue(String p, double value) {
    switch (p) {
      case 'hr':
        hr = value;
        break;
      case 'systolic':
        bpSyst = value;
        break;
      case 'diastolic':
        bpDiast = value;
        break;
      case 'spo2':
        spo2 = value;
        break;
      case 'temp':
        temp = value;
        break;
      case 'bs':
        bloodSugar = value;
        break;
      case 'hrv':
        hrv = value;
        break;
      case 'stress':
        stress = value;
        break;
    }
  }

  double completeness() {
    int filled = 0;
    if (hr != null) filled++;
    if (bpSyst != null) filled++;
    if (bpDiast != null) filled++;
    if (spo2 != null) filled++;
    if (temp != null) filled++;
    if (bloodSugar != null) filled++;
    if (hrv != null) filled++;
    if (stress != null) filled++;
    return (filled / 8.0);  //  Without 100*
  }

  bool isUsable({double minCompleteness = 0.5}) =>
      completeness() >= minCompleteness;
}

class HealthAIModel {
  List<HealthDataPoint> aggregatedData = [];

  void aggregateRawData(
    List<RawHealthRecord> rawRecords, {
    Duration window = const Duration(minutes: 5),
  }) {
    aggregatedData.clear();
    if (rawRecords.isEmpty) return;

    rawRecords.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final Map<DateTime, HealthDataPoint> buckets = {};

    for (var record in rawRecords) {
      final bucketTime = _roundToWindow(record.timestamp, window);
      buckets.putIfAbsent(
        bucketTime,
        () => HealthDataPoint(timestamp: bucketTime),
      );
      buckets[bucketTime]!.addValue(record.parameter, record.value);
    }

    aggregatedData =
        buckets.values.where((p) => p.isUsable(minCompleteness: 0.5)).toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  DateTime _roundToWindow(DateTime t, Duration window) {
    final millis = t.millisecondsSinceEpoch;
    final windowMillis = window.inMilliseconds;
    final rounded = (millis ~/ windowMillis) * windowMillis;
    return DateTime.fromMillisecondsSinceEpoch(rounded, isUtc: t.isUtc);
  }

  Map<String, dynamic> analyze({Duration? trendPeriod}) {
    if (aggregatedData.isEmpty) return {'error': 'No data'};

    final recent = aggregatedData.last;
    final anomalies = detectAnomalies();

    return {
      'healthScore': _computeHealthScore(recent),
      'currentState': _assessCurrentState(recent),
      'alerts': _generateAlerts(recent),
      'trends': calculateTrends(period: trendPeriod),
      'correlations': _calculateKeyCorrelations(),
      'completeness': recent.completeness(),
      'anomaly': anomalies,
      'dataPointsCount': aggregatedData.length,
    };
  }

  // String _assessCurrentState(HealthDataPoint p) {
  //   if (p.hr != null && p.hr! > maxHr) return "Increased heart rate [> $maxHr]";
  //   if (p.hrv != null && p.hrv! < minHRVI) return "Low HRV [< $minHRVI]";
  //   if (p.stress != null && p.stress! > stressMaxI) return "High stress [> $stressMaxI]";
  //   if (p.spo2 != null && p.spo2! < minSpO2) return "Low saturation [< $minSpO2]";
  //   if (p.bloodSugar != null && (p.bloodSugar! > bsMax || p.bloodSugar! < bsMin)) {
  //     return "Sugar deviation ∉ ($bsMin..$bsMax)";
  //   }
  //   if (p.temp != null && (p.temp! > maxTempI || p.temp! < minTempI)) {
  //     return "Temperature deviation ∉ ($minTempI..$maxTempI)";
  //   }
  //   return "General condition is normal";
  // }
  //
  // int _computeHealthScore(HealthDataPoint p) {
  //   double score = 100.0;
  //   if (p.hr != null && (p.hr! > maxHr || p.hr! < minHr)) {
  //     score -= 15;
  //   }
  //   if (p.hrv != null && p.hrv! < minHRVII) {
  //     score -= 20;
  //   }
  //   if (p.stress != null && p.stress! > stressMaxII) {
  //     score -= 18;
  //   }
  //   if (p.spo2 != null && p.spo2! < minSpO2) {
  //     score -= 15;
  //   }
  //   if (p.bloodSugar != null && (p.bloodSugar! > bsMax || p.bloodSugar! < bsMin)) {
  //     score -= 20;
  //   }
  //   if (p.temp != null && (p.temp! > maxTempII || p.temp! < minTempII)) {
  //     score -= 12;
  //   }
  //   return score.clamp(0, 100).toInt();
  // }

  ///////////////////////////////////////////////////////////////////////////////////////////
  /// Возвращает anomaly score и список аномальных параметров
  Map<String, dynamic> detectAnomalies({double zThreshold = 2.5}) {
    if (aggregatedData.length < 10) {
      return {
        'isAnomaly': false,
        'score': 0.0,
        'anomalousParameters': <String>[],
        'message': 'Insufficient data for anomaly detection',
      };
    }

    final recent = aggregatedData.last;
    final history = aggregatedData.sublist(0, aggregatedData.length - 1);

    final Map<String, double?> currentValues = {
      'hr': recent.hr,
      'hrv': recent.hrv,
      'stress': recent.stress,
      'spo2': recent.spo2,
      'temp': recent.temp,
      'bloodSugar': recent.bloodSugar,
    };

    final List<String> anomalous = [];
    double totalScore = 0;
    int counted = 0;

    currentValues.forEach((param, value) {
      if (value == null) return;

      final values = history
          .map((p) => _getParam(p, param))
          .whereType<double>()
          .toList();

      if (values.length < 5) return;

      final mean = values.average;
      final std = _stdDev(values, mean);

      if (std == 0) return;

      final z = (value - mean).abs() / std;
      totalScore += z;
      counted++;

      if (z > zThreshold) {
        anomalous.add(param);
      }
    });

    final avgScore = counted > 0 ? totalScore / counted : 0.0;
    final isAnomaly = anomalous.isNotEmpty || avgScore > zThreshold;

    return {
      'isAnomaly': isAnomaly,
      'score': double.parse(avgScore.toStringAsFixed(2)),
      'anomalousParameters': anomalous,
      'message': isAnomaly
          ? 'Anomaly detected in: ${anomalous.join(', ')}'
          : 'No significant anomalies',
    };
  }

  double? _getParam(HealthDataPoint p, String param) {
    switch (param) {
      case 'hr': return p.hr;
      case 'hrv': return p.hrv;
      case 'stress': return p.stress;
      case 'spo2': return p.spo2;
      case 'temp': return p.temp;
      case 'bloodSugar': return p.bloodSugar;
      default: return null;
    }
  }

  double _stdDev(List<double> values, double mean) {
    if (values.length < 2) return 0;
    final sum = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b);
    return sqrt(sum / (values.length - 1));
  }

  ///////////////////////////////////////////////////////////////////////////////////////////

  String _assessCurrentState(HealthDataPoint p) {
    if (p.hr != null && p.hr! > HealthThresholds.hrHighWarning) {
      return "Elevated heart rate";
    }
    if (p.hrv != null && p.hrv! < HealthThresholds.hrvLow) {
      return "Low HRV (poor recovery)";
    }
    if (p.stress != null && p.stress! > HealthThresholds.stressHigh) {
      return "High stress level";
    }
    if (p.spo2 != null && p.spo2! < HealthThresholds.spo2Warning) {
      return "Reduced oxygen saturation";
    }
    if (p.bloodSugar != null &&
        (p.bloodSugar! > HealthThresholds.sugarHigh ||
            p.bloodSugar! < HealthThresholds.sugarLow)) {
      return "Blood sugar deviation";
    }
    if (p.temp != null &&
        (p.temp! > HealthThresholds.tempHigh || p.temp! < HealthThresholds.tempLow)) {
      return "Temperature deviation";
    }
    return "Within normal range";
  }

  int _computeHealthScore(HealthDataPoint p) {
    double score = 100.0;

    if (p.hr != null) {
      if (p.hr! > HealthThresholds.hrHighWarning || p.hr! < HealthThresholds.hrLow) {
        score -= 15;
      }
    }
    if (p.hrv != null && p.hrv! < HealthThresholds.hrvWarning) {
      score -= 20;
    }
    if (p.stress != null && p.stress! > HealthThresholds.stressWarning) {
      score -= 18;
    }
    if (p.spo2 != null && p.spo2! < HealthThresholds.spo2Warning) {
      score -= 15;
    }
    if (p.bloodSugar != null &&
        (p.bloodSugar! > HealthThresholds.sugarHigh ||
            p.bloodSugar! < HealthThresholds.sugarLow)) {
      score -= 20;
    }
    if (p.temp != null &&
        (p.temp! > HealthThresholds.tempCriticalHigh || p.temp! < HealthThresholds.tempLow)) {
      score -= 12;
    }

    return score.clamp(0, 100).toInt();
  }

  List<String> _generateAlerts(HealthDataPoint p) {
    final alerts = <String>[];

    if (p.hr != null && p.hr! > HealthThresholds.hrHighAlert) {
      alerts.add("Tachycardia!");
    }
    if (p.hrv != null && p.hrv! < HealthThresholds.hrvCritical) {
      alerts.add("Critically low HRV");
    }
    if (p.spo2 != null && p.spo2! < HealthThresholds.spo2Critical) {
      alerts.add("Hypoxemia!");
    }
    if (p.stress != null && p.stress! > HealthThresholds.stressCritical) {
      alerts.add("Extreme stress level");
    }

    return alerts;
  }

  List<HealthDataPoint> _getLastHours(int hours) {
    final cutoff = DateTime.now().subtract(Duration(hours: hours));
    return aggregatedData.where((p) => p.timestamp.isAfter(cutoff)).toList();
  }

  Map<String, String> calculateTrends({Duration? period}) {
    List<HealthDataPoint> points;

    if (period == null) {
      points = aggregatedData;
    } else {
      final cutoff = DateTime.now().subtract(period);
      points = aggregatedData.where((p) => p.timestamp.isAfter(cutoff)).toList();
    }

    if (points.length < 3) {
      return {
        'hrTrend': 'insufficient data',
        'hrvTrend': 'insufficient data',
        'stressTrend': 'insufficient data',
        'bloodSugarTrend': 'insufficient data',
      };
    }

    return {
      'hrTrend': _trendStatus(_linearTrend(points.map((e) => e.hr).whereType<double>().toList())),
      'hrvTrend': _trendStatus(_linearTrend(points.map((e) => e.hrv).whereType<double>().toList())),
      'stressTrend': _trendStatus(_linearTrend(points.map((e) => e.stress).whereType<double>().toList())),
      'bloodSugarTrend':_trendStatus( _linearTrend(points.map((e) => e.bloodSugar).whereType<double>().toList())),
    };
  }

  String _trendStatus(double slope) {
    const threshold = 0.15;

    if (slope > threshold) return '↑ Rising';
    if (slope < -threshold) return '↓ Falling';
    return ' ̶ Stable';
  }

  double _linearTrend(List<double> values) {
    if (values.length < 2) return 0.0;
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    for (int i = 0; i < values.length; i++) {
      sumX += i;
      sumY += values[i];
      sumXY += i * values[i];
      sumX2 += i * i;
    }
    final n = values.length.toDouble();
    return (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
  }

  Map<String, dynamic> _calculateKeyCorrelations() {
    if (aggregatedData.length < 5) {
      return {
        'hr_hrv': null,
        'hr_hrv_text': 'Insufficient data',
        'stress_hrv': null,
        'stress_hrv_text': 'Insufficient data',
      };
    }

    final hrList = aggregatedData.map((e) => e.hr).whereType<double>().toList();
    final hrvList = aggregatedData.map((e) => e.hrv).whereType<double>().toList();
    final stressList = aggregatedData.map((e) => e.stress).whereType<double>().toList();

    final hrHrvCorr = _correlation(hrList, hrvList);
    final stressHrvCorr = _correlation(stressList, hrvList);

    return {
      'hr_hrv': hrHrvCorr,
      'hr_hrv_text': _interpretCorrelation(hrHrvCorr),
      'stress_hrv': stressHrvCorr,
      'stress_hrv_text': _interpretCorrelation(stressHrvCorr),
    };
  }

  String _interpretCorrelation(double corr) {
    if (corr < -0.6) return 'Strong negative (normal)';
    if (corr < -0.3) return 'Moderate negative';
    if (corr < 0.3) return 'Weak / none';
    return 'Positive (needs attention)';
  }

  double _correlation(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 2) return 0.0;
    final meanX = x.average;
    final meanY = y.average;
    double num = 0, denX = 0, denY = 0;
    for (int i = 0; i < x.length; i++) {
      final dx = x[i] - meanX;
      final dy = y[i] - meanY;
      num += dx * dy;
      denX += dx * dx;
      denY += dy * dy;
    }
    return denX > 0 && denY > 0 ? num / (sqrt(denX) * sqrt(denY)) : 0.0;
  }

  // List<String> _generateAlerts(HealthDataPoint p) {
  //   final alerts = <String>[];
  //   if (p.hr != null && p.hr! > alertHr) alerts.add("Tachycardia");
  //   if (p.hrv != null && p.hrv! < alertHRV) alerts.add("Critically low HRV");
  //   if (p.spo2 != null && p.spo2! < alertSpO2) alerts.add("Hypoxemia!");
  //   if (p.stress != null && p.stress! > alertStress) alerts.add("Extreme stress");
  //   return alerts;
  // }

}

List<RawHealthRecord> fetchRawRecords(List<TraceDb> traceDb) {
  List<RawHealthRecord> result = [];
  if (traceDb.isEmpty) {
    return result;
  }
  for (int i = 0; i < traceDb.length; i++) {
    DateTime time = parseCustomDate(traceDb[i].time);
    String parameter = traceDb[i].measure;
    dynamic value = parseValue(traceDb[i].value);
    if (value != null) {
      if (value is double) {
        RawHealthRecord record = RawHealthRecord(
          timestamp: time,
          parameter: parameter,
          value: value,
        );
        result.add(record);
      } else if (value is List<double>) {
        RawHealthRecord record = RawHealthRecord(
          timestamp: time,
          parameter: "systolic",
          value: value[0],
        );
        result.add(record);
        record = RawHealthRecord(
          timestamp: time,
          parameter: "diastolic",
          value: value[1],
        );
        result.add(record);
      }
    }
  }
  return result;
}

dynamic parseValue(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  // Check for double/double
  if (trimmed.contains('/')) {
    final parts = trimmed.split('/').map((e) => e.trim()).toList();
    if (parts.length == 2) {
      final double? v1 = double.tryParse(parts[0]);
      final double? v2 = double.tryParse(parts[1]);
      if (v1 != null && v2 != null) {
        return [v1, v2];
      }
    }
  }

  // Single double
  final double? num = double.tryParse(trimmed);
  if (num != null) {
    return num;
  }
  return null;
}

DateTime parseCustomDate(String dateStr) {
  // DataTime string format:
  final format = DateFormat('yyyy/MM/dd HH:mm:ss.SSS');
  return format.parse(dateStr);
}

void buildHealthAiModel(List<TraceDb> traceDb) {
  print("traceDb# ${traceDb.length}");
  final model = HealthAIModel();
  final rawData = /*await*/ fetchRawRecords(traceDb); // from DB
  model.aggregateRawData(rawData, window: const Duration(minutes: 5));
  final result = model.analyze();
  // int x = 0;
  // int y = x;
}
