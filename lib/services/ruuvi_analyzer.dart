import 'ruuvi_thresholds.dart';
import '../models/ruuvi_analysis.dart';
import '../models/ruuvi_sample.dart';

class RuuviAnalyzer {
  RuuviAnalysis analyze(List<RuuviSample> samples) {
    if (samples.isEmpty) {
      return _empty();
    }

    final now = DateTime.now();
    final last = samples.last;

    return RuuviAnalysis(
      temperature: _analyzeMetric(
        samples: samples,
        getter: (s) => s.temperature,
        current: last.temperature,
        now: now,
        name: 'Temperature',
        unit: '°C',
        mildDelta: RuuviThresholds.temperatureMildDelta,
        strongDelta: RuuviThresholds.temperatureStrongDelta,
        mildRate: RuuviThresholds.temperatureMildRate,
        strongRate: RuuviThresholds.temperatureStrongRate,
      ),
      humidity: _analyzeMetric(
        samples: samples,
        getter: (s) => s.humidity,
        current: last.humidity,
        now: now,
        name: 'Humidity',
        unit: '%',
        mildDelta: RuuviThresholds.humidityMildDelta,
        strongDelta: RuuviThresholds.humidityStrongDelta,
        mildRate: RuuviThresholds.humidityMildRate,
        strongRate: RuuviThresholds.humidityStrongRate,
      ),
      pressure: _analyzeMetric(
        samples: samples,
        getter: (s) => s.pressure,
        current: last.pressure,
        now: now,
        name: 'Pressure',
        unit: 'hPa',
        mildDelta: RuuviThresholds.pressureMildDelta,
        strongDelta: RuuviThresholds.pressureStrongDelta,
        mildRate: RuuviThresholds.pressureMildRate,
        strongRate: RuuviThresholds.pressureStrongRate,
      ),
      battery: _analyzeMetric(
        samples: samples,
        getter: (s) => s.battery,
        current: last.battery,
        now: now,
        name: 'Battery',
        unit: 'V',
        mildDelta: RuuviThresholds.batteryMildDelta,
        strongDelta: RuuviThresholds.batteryStrongDelta,
        mildRate: RuuviThresholds.batteryMildRate,
        strongRate: RuuviThresholds.batteryStrongRate,
        isBattery: true,
      ),
      analyzedAt: now,
      sampleCount: samples.length,
    );
  }

  MetricTrend _analyzeMetric({
    required List<RuuviSample> samples,
    required double Function(RuuviSample) getter,
    required double current,
    required DateTime now,
    required String name,
    required String unit,
    required double mildDelta,
    required double strongDelta,
    required double mildRate,
    required double strongRate,
    bool isBattery = false,
  }) {
    final avg1h = _average(samples, getter, now, const Duration(hours: 1));
    final avg6h = _average(samples, getter, now, const Duration(hours: 6));
    final avg24h = _average(samples, getter, now, const Duration(hours: 24));
    final slope = _slopePerHour(
      samples,
      getter,
      now,
      const Duration(hours: 3),
    );

    AnomalyLevel level = AnomalyLevel.none;
    String? reason;

    // Deviation from 1-hour average
    if (avg1h != null) {
      final delta = (current - avg1h).abs();
      if (delta >= strongDelta) {
        level = AnomalyLevel.strong;
        reason =
        '$name: deviation ${delta.toStringAsFixed(2)} $unit from 1h average';
      } else if (delta >= mildDelta) {
        level = AnomalyLevel.mild;
        reason =
        '$name: mild deviation ${delta.toStringAsFixed(2)} $unit from 1h average';
      }
    }

    // Rate of change
    if (slope != null) {
      final rate = slope.abs();
      if (rate >= strongRate) {
        level = AnomalyLevel.strong;
        reason =
        '$name: rapid change ${slope.toStringAsFixed(2)} $unit/h';
      } else if (rate >= mildRate && level.index < AnomalyLevel.mild.index) {
        level = AnomalyLevel.mild;
        reason =
        '$name: noticeable trend ${slope.toStringAsFixed(2)} $unit/h';
      }
    }

    // Battery absolute levels
    if (isBattery) {
      if (current < RuuviThresholds.batteryCriticalV) {
        level = AnomalyLevel.strong;
        reason =
        'Battery critically low: ${current.toStringAsFixed(3)} V';
      } else if (current < RuuviThresholds.batteryLowV &&
          level == AnomalyLevel.none) {
        level = AnomalyLevel.mild;
        reason = 'Battery low: ${current.toStringAsFixed(3)} V';
      }
    }

    return MetricTrend(
      current: current,
      avg1h: avg1h,
      avg6h: avg6h,
      avg24h: avg24h,
      slopePerHour: slope,
      anomaly: level,
      anomalyReason: reason,
    );
  }

  double? _average(
      List<RuuviSample> samples,
      double Function(RuuviSample) getter,
      DateTime now,
      Duration window,
      ) {
    final from = now.subtract(window);
    final subset =
    samples.where((s) => !s.timestamp.isBefore(from)).toList();
    if (subset.length < 3) return null;

    final sum = subset.fold<double>(0, (acc, s) => acc + getter(s));
    return sum / subset.length;
  }

  /// Linear regression slope in units per hour.
  double? _slopePerHour(
      List<RuuviSample> samples,
      double Function(RuuviSample) getter,
      DateTime now,
      Duration window,
      ) {
    final from = now.subtract(window);
    final subset =
    samples.where((s) => !s.timestamp.isBefore(from)).toList();

    if (subset.length < RuuviThresholds.minPointsForTrend) {
      return null;
    }

    final t0 = subset.first.timestamp.millisecondsSinceEpoch.toDouble();
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumXX = 0;
    final n = subset.length;

    for (final s in subset) {
      final x =
          (s.timestamp.millisecondsSinceEpoch - t0) / 3600000.0; // hours
      final y = getter(s);
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumXX += x * x;
    }

    final denom = n * sumXX - sumX * sumX;
    if (denom.abs() < 1e-9) return null;

    return (n * sumXY - sumX * sumY) / denom;
  }

  RuuviAnalysis _empty() {
    const empty = MetricTrend(current: 0);
    return RuuviAnalysis(
      temperature: empty,
      humidity: empty,
      pressure: empty,
      battery: empty,
      analyzedAt: DateTime.now(),
      sampleCount: 0,
    );
  }
}
