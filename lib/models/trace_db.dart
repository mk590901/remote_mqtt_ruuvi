import 'package:equatable/equatable.dart';
import 'trace.dart';

class TraceDb extends Equatable {
  final String id;
  final String time;
  final int rssi;
  final int battery;
  final String measure;
  final String value;
  final String units;
  final String transmitter_type;
  final String transmitter_mac;
  final String ble_name;
  final String ble_mac;
  final bool online;

  const TraceDb({
    required this.id,
    required this.time,
    required this.rssi,
    required this.battery,
    required this.measure,
    required this.value,
    required this.units,
    required this.transmitter_type,
    required this.transmitter_mac,
    required this.ble_name,
    required this.ble_mac,
    required this.online,
  });

  factory TraceDb.fromJson(String id, Map<String, dynamic> json) {
    return TraceDb(
      id: id,
      rssi:             json['rssi'] ?? 0,
      battery:          json['battery'] ?? 0,
      measure:          json['measure'] ?? '',
      value:            json['value'] ?? '',
      units:            json['units'] ?? '',
      transmitter_type: json['transmitter_type'] ?? '',
      transmitter_mac:  json['transmitter_mac'] ?? '',
      ble_name:         json['ble_name'] ?? '',
      ble_mac:          json['ble_mac'] ?? '',
      time:             json['time'] ?? '',
      online:           json['online'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time'    : time,
      'rssi'    : rssi,
      'battery' : battery,
      'measure' : measure,
      'value'   : value,
      'units'   : units,
      'transmitter_type' : transmitter_type,
      'transmitter_mac' : transmitter_mac,
      'ble_name' : ble_name,
      'ble_mac' : ble_mac,
      'online': online,
    };
  }

  @override
  List<Object?> get props => [id, time, rssi, transmitter_type, transmitter_mac, ble_name, online,/* online*/];

  Trace toTrace() {

    List<Parameter> paramsList = [];
    paramsList.add(Parameter(name: 'rssi',              value: '$rssi'));
    paramsList.add(Parameter(name: 'battery',           value: '$battery'));
    paramsList.add(Parameter(name: 'measure',           value: measure));
    paramsList.add(Parameter(name: 'value',             value: value));
    paramsList.add(Parameter(name: 'units',             value: units));
    paramsList.add(Parameter(name: 'transmitter_type',  value: transmitter_type));
    paramsList.add(Parameter(name: 'transmitter_mac',   value: transmitter_mac));
    paramsList.add(Parameter(name: 'ble_name',          value: ble_name));
    paramsList.add(Parameter(name: 'ble_mac',           value: ble_mac));
    paramsList.add(Parameter(name: 'time',              value: time));

    return Trace( title: '$ble_name @ $ble_mac', isOnline: online, parameters: paramsList);

  }
}
