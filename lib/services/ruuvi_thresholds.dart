/// Thresholds for RuuviTag trend analysis and anomaly detection.
///
/// Tune these values for a specific room / environment.
/// Units: temperature — °C, humidity — %, pressure — hPa, battery — V.
class RuuviThresholds {
  RuuviThresholds._();

  // ─── Analyzer general settings ───────────────────────────────

  /// Maximum number of samples kept in history.
  /// At ~1 sample per 1–2 minutes this covers roughly one day.
  /// Older samples are dropped when the limit is exceeded.
  static const int maxSamples = 2000;

  /// Minimum number of points in a window required to compute a reliable trend (slope).
  /// Slope is not calculated if there are fewer points.
  static const int minPointsForTrend = 5;

  /// How often analysis is recalculated, in seconds.
  /// No need to recompute trends on every advertising packet.
  static const int analysisIntervalSec = 20;

  // ─── Temperature (°C) ────────────────────────────────────────

  /// Mild deviation of current temperature from the 1-hour average.
  /// Typical cases: door opened / short ventilation.
  static const double temperatureMildDelta = 1.5;

  /// Strong deviation of current temperature from the 1-hour average.
  /// Possible fault or abrupt change in heating/cooling mode.
  static const double temperatureStrongDelta = 3.0;

  /// Mild rate of temperature change, °C per hour.
  /// Noticeable but still “normal” trend.
  static const double temperatureMildRate = 2.0;

  /// Strong rate of temperature change, °C per hour.
  /// Rapid heating or cooling of the room.
  static const double temperatureStrongRate = 4.0;

  // ─── Humidity (%) ────────────────────────────────────────────

  /// Mild deviation of humidity from the 1-hour average, %.
  /// E.g. brief ventilation, kettle boiled.
  static const double humidityMildDelta = 8.0;

  /// Strong deviation of humidity from the 1-hour average, %.
  /// Sudden change of conditions (shower, open window in rain, etc.).
  static const double humidityStrongDelta = 15.0;

  /// Mild rate of humidity change, % per hour.
  static const double humidityMildRate = 12.0;

  /// Strong rate of humidity change, % per hour.
  static const double humidityStrongRate = 25.0;

  // ─── Pressure (hPa) ──────────────────────────────────────────

  /// Mild deviation of pressure from the 1-hour average, hPa.
  /// Small atmospheric fluctuations.
  static const double pressureMildDelta = 2.5;

  /// Strong deviation of pressure from the 1-hour average, hPa.
  /// Significant weather front / strong weather change.
  static const double pressureStrongDelta = 5.0;

  /// Mild rate of pressure change, hPa per hour.
  static const double pressureMildRate = 3.0;

  /// Strong rate of pressure change, hPa per hour.
  /// Rapid drop is often linked to an approaching cyclone.
  static const double pressureStrongRate = 6.0;

  // ─── Battery (V) ─────────────────────────────────────────────

  /// Mild deviation of voltage from the 1-hour average, V.
  /// Rare under normal conditions — battery changes slowly.
  static const double batteryMildDelta = 0.05;

  /// Strong deviation of voltage from the 1-hour average, V.
  /// Suspicious: measurement noise or power issue.
  static const double batteryStrongDelta = 0.12;

  /// Mild discharge rate, V per hour.
  /// Above normal for a CR2477 in advertising mode.
  static const double batteryMildRate = 0.03;

  /// Strong discharge rate, V per hour.
  /// Abnormally fast energy consumption.
  static const double batteryStrongRate = 0.08;

  /// Critically low battery voltage, V.
  /// Time to replace the cell (CR2477).
  static const double batteryCriticalV = 2.50;

  /// Low battery voltage, V.
  /// Warning: remaining capacity is low.
  static const double batteryLowV = 2.70;
}
