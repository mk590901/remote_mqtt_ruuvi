// BLoC part
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../gui_adapter/service_adapter.dart';

// Events
abstract class RemoteBleEvent {}

class StartScan     extends RemoteBleEvent {}
class FinalScan     extends RemoteBleEvent {}

class SelectDevice  extends RemoteBleEvent {
  final String selectedDeviceName;
  SelectDevice(this.selectedDeviceName);
}

class SetError  extends RemoteBleEvent {
  final String message;
  SetError(this.message);
}

class StartSession  extends RemoteBleEvent {}
class FinalSession  extends RemoteBleEvent {}
class ClearError    extends RemoteBleEvent {}
class Sync     extends RemoteBleEvent {}

class ConfirmStartScan    extends RemoteBleEvent {}
class ConfirmFinalScan    extends RemoteBleEvent {}
class ConfirmStartSession extends RemoteBleEvent {}
class ConfirmFinalSession extends RemoteBleEvent {}

class ConfirmSync         extends RemoteBleEvent {
  final bool startedSession;
  final bool startedScan;
  ConfirmSync (this.startedSession, this.startedScan);
}

class UpdateTransmitter   extends RemoteBleEvent {
  final String transmitterName;
  final String transmitterMAC;
  UpdateTransmitter (this.transmitterName, this.transmitterMAC);
}

class UpdateBleDevice   extends RemoteBleEvent {
  final String? bleMAC;
  final int? bleRSSI;
  final String? discoveryTime;
  final bool? isOnline;
  UpdateBleDevice (this.bleMAC, this.bleRSSI, this.discoveryTime, this.isOnline);
}

class UpdateState   extends RemoteBleEvent {
  final String? state;
  final String? measureType;
  final String? value;
  UpdateState (this.state, this.measureType, this.value);
}

// States
class RemoteBleState {
  final bool              error;
  final String?           errorMessage;
  final String            deviceName;
  final String            macAddress;
  final int               rssi;
  final String            transmitterMAC;
  final String            transmitterName;
  final String?           discoveryTime;
  final String?           state;
  final String?           measureType;
  final String?           value;
  final bool              isSessionStarted;
  final bool              isScanning;
  final bool              isOnline;

  RemoteBleState({
    this.error = false,
    this.errorMessage,
    this.deviceName = '',
    this.macAddress = '',
    this.rssi = 0,
    this.transmitterMAC = '',
    this.transmitterName = '',
    this.discoveryTime,
    this.state,
    this.measureType,
    this.value,
    this.isSessionStarted = false,
    this.isScanning = false,
    this.isOnline = false,
  });

  RemoteBleState copyWith({
    bool? error,
    String? errorMessage,
    String? deviceName,
    String? macAddress,
    int? rssi,
    String? transmitterMAC,
    String? transmitterName,
    String? discoveryTime,
    String? state,
    String? measureType,
    String? value,
    bool? isSessionStarted,
    bool? isScanning,
    bool? isOnline,
  }) {

    print("copyWith [$deviceName]:[$macAddress]");

    return RemoteBleState(
      error: error ?? this.error,
      errorMessage: errorMessage ?? this.errorMessage,
      deviceName: deviceName ?? this.deviceName,
      macAddress: macAddress ?? this.macAddress,
      rssi: rssi ?? this.rssi,
      transmitterMAC: transmitterMAC ?? this.transmitterMAC,
      transmitterName: transmitterName ?? this.transmitterName,
      discoveryTime: discoveryTime ?? this.discoveryTime,
      state: state ?? this.state,
      measureType: measureType ?? this.measureType,
      value: value ?? this.value,
      isSessionStarted: isSessionStarted ?? this.isSessionStarted,
      isScanning: isScanning ?? this.isScanning,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

// Bloc
class RemoteBleBloc extends Bloc<RemoteBleEvent, RemoteBleState> {

  RemoteBleBloc() : super(RemoteBleState()) {
    ServiceAdapter.instance()?.setBleBloc(this);
    on<StartScan>(_onStartScan);
    on<FinalScan>(_onFinalScan);
    on<SelectDevice>(_onSelectDevice);
    on<StartSession>(_onStartSession);
    on<FinalSession>(_onFinalSession);
    on<Sync>(_onSync);
    on<ClearError>((event, emit) {
      emit(state.copyWith(error: false, errorMessage: null));
    });
    on<SetError>((event, emit) {
      emit(state.copyWith(error: true, errorMessage: event.message));
    });

    on<ConfirmStartScan>(_onConfirmStartScan);
    on<ConfirmFinalScan>(_onConfirmFinalScan);
    on<ConfirmStartSession>(_onConfirmStartSession);
    on<ConfirmFinalSession>(_onConfirmFinalSession);
    on<ConfirmSync>(_onConfirmSync);
    on<UpdateTransmitter>(_onUpdateTransmitter);
    on<UpdateBleDevice>(_UpdateBleDevice);
    on<UpdateState>(_UpdateState);

  }

  Future<void> _onFinalSession(FinalSession event, Emitter<RemoteBleState> emit) async {

    String  message = "";

    bool? mqttOk = ServiceAdapter.instance()?.isMQTTOk();
    if (mqttOk == null || mqttOk == false) {
      message = "MQTT client problems!";
    }
    else
    if (!state.isSessionStarted)  {
      message = "First start session.";
    }

    if (message.isNotEmpty) {
      emit(state.copyWith(error: true, errorMessage: message,));
      return;
    }

    print ("onFinalSession->${state.deviceName}");

    ServiceAdapter.instance()?.sendCommand("final-session", state.deviceName);

  }

  Future<void> _onStartSession(StartSession event, Emitter<RemoteBleState> emit) async {

    String  message = "";

    bool? mqttOk = ServiceAdapter.instance()?.isMQTTOk();
    if (mqttOk == null || mqttOk == false) {
      message = "MQTT client problems!";
    }
    else
    if (state.isSessionStarted) {
      message = "Session already started.";
    }
    else
    if (state.deviceName.isEmpty) {
      message = "BLE deviceName isn't defined.\nSelect device name from combo.";
    }

    if (message.isNotEmpty) {
      emit(state.copyWith(error: true, errorMessage: message,));
      return;
    }

    print ("onStartSession->${state.deviceName}");

    ServiceAdapter.instance()?.sendCommand("start-session", state.deviceName);

  }

  //  We simply transfer the device name from the ComboBox to the chip control form
  Future<void> _onSelectDevice(SelectDevice event, Emitter<RemoteBleState> emit) async {

    print ("_onSelectDevice->[${state.isSessionStarted}][${state.isScanning}]");

    if (state.isScanning) {
      ServiceAdapter.instance()?.sendCommand("final-scan", state.deviceName);
    }
    if (state.isSessionStarted) {
      emit(state.copyWith(deviceName: event.selectedDeviceName,));
    }
    else {
      emit(state.copyWith(deviceName: event.selectedDeviceName,
          macAddress: '-', transmitterMAC: '-', transmitterName: '-'));
    }

    ServiceAdapter.instance()?.setDeviceName(state.deviceName);

  }

  Future<void> _onFinalScan(FinalScan event, Emitter<RemoteBleState> emit) async {

    String  message = "";

    bool? mqttOk = ServiceAdapter.instance()?.isMQTTOk();
    if (mqttOk == null || mqttOk == false) {
      message = "MQTT client problems!";
    }
    else
    if (!state.isScanning) {
      message = "First start scan should be done.";
    }

    if (message.isNotEmpty) {
      emit(state.copyWith(error: true, errorMessage: message,));
      return;
    }

    print ("_onFinalScan->${state.deviceName}");

    ServiceAdapter.instance()?.sendCommand("final-scan", state.deviceName);

  }

  Future<void> _onStartScan(StartScan event, Emitter<RemoteBleState> emit) async {
    String  message = "";

    bool? mqttOk = ServiceAdapter.instance()?.isMQTTOk();
    if (mqttOk == null || mqttOk == false) {
       message = "MQTT client problems!";
    }
    else
    if (!state.isSessionStarted)  {
      message = "First start session.";
    }
    else
    if (state.isScanning) {
       message = "Already scanning.";
    }

    if (message.isNotEmpty) {
      emit(state.copyWith(error: true, errorMessage: message,));
      return;
    }

    print ("_onStartScan->${state.deviceName}");

    ServiceAdapter.instance()?.sendCommand("start-scan", state.deviceName);

  }


  Future<void> _onSync(Sync event, Emitter<RemoteBleState> emit) async {
    String  message = "";

    bool? mqttOk = ServiceAdapter.instance()?.isMQTTOk();
    if (mqttOk == null || mqttOk == false) {
      message = "MQTT client problems!";
    }

    if (message.isNotEmpty) {
      emit(state.copyWith(error: true, errorMessage: message,));
      return;
    }

    print ("_onCheckSink->${state.deviceName}");

    ServiceAdapter.instance()?.sendCommand("sync", state.deviceName);

  }

  Future<void> _onConfirmSync(ConfirmSync event, Emitter<RemoteBleState> emit) async {
    emit(state.copyWith(isOnline: true, isSessionStarted: event.startedSession, isScanning: event.startedScan));
  }

  Future<void> _onConfirmStartScan(ConfirmStartScan event, Emitter<RemoteBleState> emit) async {
    emit(state.copyWith(isScanning: true,));
  }

  Future<void> _onConfirmFinalScan(ConfirmFinalScan event, Emitter<RemoteBleState> emit) async {
    emit(state.copyWith(isScanning: false));
  }

  Future<void> _onConfirmStartSession(ConfirmStartSession event, Emitter<RemoteBleState> emit) async {
    emit(state.copyWith(isSessionStarted: true,));
  }

  Future<void> _onConfirmFinalSession(ConfirmFinalSession event, Emitter<RemoteBleState> emit) async {
    emit(state.copyWith(isSessionStarted: false,));
  }

  Future<void> _onUpdateTransmitter(UpdateTransmitter event, Emitter<RemoteBleState> emit) async {
    emit(state.copyWith(transmitterName: event.transmitterName, transmitterMAC: event.transmitterMAC));
  }


  Future<void> _UpdateBleDevice(UpdateBleDevice event, Emitter<RemoteBleState> emit) async {
    emit(state.copyWith(macAddress: event.bleMAC, rssi: event.bleRSSI, discoveryTime: event.discoveryTime, isOnline: event.isOnline));
  }

  Future<void> _UpdateState(UpdateState event, Emitter<RemoteBleState> emit) async {
    emit(state.copyWith(state: event.state, measureType: event.measureType, value: event.value));
  }

  late Timer? timer;

  @override
  Future<void> close() async {
    return super.close();
  }

}