class HealthThresholds {
  // Heart Rate
  static const double hrLow = 50;
  static const double hrHighWarning = 100;
  static const double hrHighAlert = 110;

  // HRV
  static const double hrvWarning = 40;
  static const double hrvLow = 35;
  static const double hrvCritical = 25;

  // Stress
  static const double stressWarning = 65;
  static const double stressHigh = 70;
  static const double stressCritical = 85;

  // SpO2
  static const double spo2Warning = 95;
  static const double spo2Critical = 92;

  // Blood Sugar (примерно, зависит от единиц)
  static const double sugarLow = 60;
  static const double sugarHigh = 160;

  // Temperature
  static const double tempLow = 35.5;
  static const double tempHigh = 37.5;
  static const double tempCriticalHigh = 37.8;
}
