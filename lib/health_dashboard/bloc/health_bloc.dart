// lib/bloc/health_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../health_ai_model.dart';
import '../../gui_adapter/service_adapter.dart';
import 'health_event.dart';
import 'health_state.dart';

class HealthBloc extends Bloc<HealthEvent, HealthState> {
  HealthBloc() : super(HealthState(
    model: HealthAIModel(),
    analysis: {},
  )) {

    ServiceAdapter.instance()?.setHealthBloc(this);

    on<LoadHealthData>(_onLoadData);
    on<AddRawRecord>(_onAddRecord);
    on<RefreshAnalysis>(_onRefreshAnalysis);
  }

  Future<void> _onLoadData(LoadHealthData event, Emitter<HealthState> emit) async {
    emit(state.copyWith(isLoading: true));

    //final rawRecords = await _fetchRawRecords();
    final List<RawHealthRecord> rawRecords = [];
    state.model.aggregateRawData(rawRecords, window: const Duration(minutes: 4));
    final newAnalysis = state.model.analyze();

    emit(state.copyWith(
      analysis: newAnalysis,
      isLoading: false,
    ));

  }

  void _onAddRecord(AddRawRecord event, Emitter<HealthState> emit) {
    print ('******* _onAddRecord *******');

    final currentRecords = _getCurrentRawRecords(); // если храните список
    state.model.aggregateRawData(currentRecords, window: const Duration(minutes: 5));
    final newAnalysis = state.model.analyze();
    emit(state.copyWith(analysis: newAnalysis));
  }

  Future<void> _onRefreshAnalysis(RefreshAnalysis event, Emitter<HealthState> emit) async {
    final newAnalysis = state.model.analyze();
    emit(state.copyWith(analysis: newAnalysis));
  }

  // Заглушка — замените на реальный fetch из БД
  Future<List<RawHealthRecord>> _fetchRawRecords() async {
    return ServiceAdapter.instance()?.getRawHRecords()??[];
  }

  List<RawHealthRecord> _getCurrentRawRecords() {
    // Если нужно хранить сырые записи — добавьте поле в состояние
    //return [];
    return ServiceAdapter.instance()?.getLocalRawHRecords()??[];
  }
}
