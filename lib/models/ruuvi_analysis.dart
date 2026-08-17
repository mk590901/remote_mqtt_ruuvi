enum AnomalyLevel { none, mild, strong }

class MetricTrend {
  final double current;
  final double? avg1h;
  final double? avg6h;
  final double? avg24h;
  final double? slopePerHour; // units in hour
  final AnomalyLevel anomaly;
  final String? anomalyReason;

  const MetricTrend({
    required this.current,
    this.avg1h,
    this.avg6h,
    this.avg24h,
    this.slopePerHour,
    this.anomaly = AnomalyLevel.none,
    this.anomalyReason,
  });
}

class RuuviAnalysis {
  final MetricTrend temperature;
  final MetricTrend humidity;
  final MetricTrend pressure;
  final MetricTrend battery;
  final DateTime analyzedAt;
  final int sampleCount;

  const RuuviAnalysis({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.battery,
    required this.analyzedAt,
    required this.sampleCount,
  });
}
