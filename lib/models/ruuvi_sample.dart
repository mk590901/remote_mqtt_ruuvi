class RuuviSample {
  final DateTime timestamp;
  final double temperature; // °C
  final double humidity;    // %
  final double pressure;    // hPa
  final double battery;     // V

  const RuuviSample({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.battery,
  });
}
