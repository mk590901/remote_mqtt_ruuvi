// lib/bloc/ruuvi_event.dart

import 'package:equatable/equatable.dart';

import '../../models/ruuvi_data.dart';

abstract class RuuviEvent extends Equatable {
  const RuuviEvent();

  @override
  List<Object?> get props => [];
}

/// New measurement from an external source (scanner, gateway, etc.).
class RuuviDataReceived extends RuuviEvent {
  final RuuviData data;

  const RuuviDataReceived(this.data);

  @override
  List<Object?> get props => [data];
}

class ClearHistory extends RuuviEvent {
  const ClearHistory();
}