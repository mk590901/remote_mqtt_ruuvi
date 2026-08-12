// --- App BLoC (for Start/Stop и Mode1/Mode2) ---
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../gui_adapter/service_adapter.dart';

abstract class AppEvent {}

class ToggleRunningEvent extends AppEvent {}

class ToggleModeEvent extends AppEvent {}

class StartService extends AppEvent {}

class StopService extends AppEvent {}

class UpdateData extends AppEvent {
  final int counter;
  UpdateData(this.counter);
}

class SendData extends AppEvent {
  final String command;
  final String data;
  SendData(this.command, this.data);
}

class AppState {
  final bool isRunning;
  final bool isServer;
  final int counter;
  final String sentData;

  AppState( {
    required this.isRunning,
    this.counter = 0,
    this.sentData = '',
    required this.isServer,
  });

  AppState copyWith({
    bool? isRunning,
    bool? isServer,
  }) {
    return AppState(
      isRunning: isRunning ?? this.isRunning,
      isServer: isServer ?? this.isServer,
    );
  }
}

class AppBloc extends Bloc<AppEvent, AppState> {

  late StreamSubscription? _dataSubscription;

  AppBloc() : super(AppState(isRunning: false, isServer: true)) {

    ServiceAdapter.instance()?.setAppBloc(this);

    on<StartService>((event, emit) async {
      print ("StartService");
      ServiceAdapter.instance()?.mqttInit();
      emit(AppState(
        isRunning: true,
        counter: state.counter,
        isServer: state.isServer,
      ));
    });

    on<StopService>((event, emit) async {
      print ("StopService");
      emit(AppState(isRunning: false, counter: 0, isServer: state.isServer, ));
      ServiceAdapter.instance()?.mqttDispose();
    });

    on<ToggleRunningEvent>((event, emit) {
      if (state.isRunning) {
        ServiceAdapter.instance()?.stop();
      }
      else {
        ServiceAdapter.instance()?.start();
      }
      emit(state.copyWith(isRunning: !state.isRunning));
    });

    on<ToggleModeEvent>((event, emit) {
      emit(state.copyWith(isServer: !state.isServer));
    });

    on<UpdateData>((event, emit) {
      emit(AppState(
        isRunning: state.isRunning,
        counter: event.counter,
        isServer: state.isServer,
      ));
    });

    on<SendData>((event, emit) async {
      print('Sending data to service: ${event.command}:${event.data}');

      emit(AppState(
        isRunning: state.isRunning,
        counter: state.counter,
        sentData: event.data, //  command?
        isServer: state.isServer,
      ));
    });

  }

  @override
  Future<void> close() {
    _dataSubscription?.cancel();
    return super.close();
  }

}
