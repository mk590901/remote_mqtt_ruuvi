import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

enum RuuviOrientation {
  flatFaceUp,      // лежит верхней стороной вверх
  flatFaceDown,    // лежит перевёрнутый
  standingUp,      // стоит вертикально
  standingDown,    // стоит вверх ногами
  onLeftSide,      // на левом боку
  onRightSide,     // на правом боку
  unknown,         // в движении / неопределённо
}

extension RuuviOrientationX on RuuviOrientation {
  String get label {
    switch (this) {
      case RuuviOrientation.flatFaceUp:
        return 'Лежит (верх вверх)';
      case RuuviOrientation.flatFaceDown:
        return 'Лежит перевёрнутый';
      case RuuviOrientation.standingUp:
        return 'Стоит вертикально';
      case RuuviOrientation.standingDown:
        return 'Стоит вверх ногами';
      case RuuviOrientation.onLeftSide:
        return 'На левом боку';
      case RuuviOrientation.onRightSide:
        return 'На правом боку';
      case RuuviOrientation.unknown:
        return 'В движении / неизвестно';
    }
  }

  IconData get icon {
    switch (this) {
      case RuuviOrientation.flatFaceUp:
        return Icons.crop_landscape;
      case RuuviOrientation.flatFaceDown:
        return Icons.flip;
      case RuuviOrientation.standingUp:
        return Icons.stay_current_portrait;
      case RuuviOrientation.standingDown:
        return Icons.screen_rotation;
      case RuuviOrientation.onLeftSide:
      case RuuviOrientation.onRightSide:
        return Icons.stay_current_landscape;
      case RuuviOrientation.unknown:
        return Icons.help_outline;
    }
  }
}

class RuuviData extends Equatable {
  final String id;
  final String mac;
  final double? temperature;
  final double? humidity;
  final double? pressure;
  final double? accelX;
  final double? accelY;
  final double? accelZ;
  final double? batteryVoltage;
  final int? txPower;
  final int? movementCounter;
  final int? sequence;
  final int rssi;
  final DateTime lastSeen;
  final RuuviOrientation orientation;   // ← новое поле

  const RuuviData({
    required this.id,
    required this.mac,
    this.temperature,
    this.humidity,
    this.pressure,
    this.accelX,
    this.accelY,
    this.accelZ,
    this.batteryVoltage,
    this.txPower,
    this.movementCounter,
    this.sequence,
    required this.rssi,
    required this.lastSeen,
    this.orientation = RuuviOrientation.unknown,
  });

  /// Вычисляет ориентацию по акселерометру
  static RuuviOrientation detectOrientation({
    required double? accelX,
    required double? accelY,
    required double? accelZ,
    double threshold = 0.7,
  }) {
    if (accelX == null || accelY == null || accelZ == null) {
      return RuuviOrientation.unknown;
    }

    final x = accelX.abs();
    final y = accelY.abs();
    final z = accelZ.abs();

    final magnitude = accelX * accelX + accelY * accelY + accelZ * accelZ;
    if (magnitude < 0.6 || magnitude > 1.5) {
      return RuuviOrientation.unknown;
    }

    if (z > threshold && z >= x && z >= y) {
      return accelZ > 0
          ? RuuviOrientation.flatFaceUp
          : RuuviOrientation.flatFaceDown;
    }
    if (y > threshold && y >= x && y >= z) {
      return accelY > 0
          ? RuuviOrientation.standingUp
          : RuuviOrientation.standingDown;
    }
    if (x > threshold && x >= y && x >= z) {
      return accelX > 0
          ? RuuviOrientation.onRightSide
          : RuuviOrientation.onLeftSide;
    }

    return RuuviOrientation.unknown;
  }

  @override
  List<Object?> get props => [
    id,
    mac,
    temperature,
    humidity,
    pressure,
    accelX,
    accelY,
    accelZ,
    batteryVoltage,
    txPower,
    movementCounter,
    sequence,
    rssi,
    lastSeen,
    orientation,
  ];
}