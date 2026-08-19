import 'package:flutter_bloc/flutter_bloc.dart';
import '../ruuvi_thresholds.dart';
import '../../models/ruuvi_data.dart';
import '../../models/ruuvi_sample.dart';
import '../ruuvi_analyzer.dart';
import 'ruuvi_event.dart';
import 'ruuvi_state.dart';
import '../../gui_adapter/service_adapter.dart';

class RuuviBloc extends Bloc<RuuviEvent, RuuviState> {
  final RuuviAnalyzer _analyzer;

  RuuviBloc({RuuviAnalyzer? analyzer})
      : _analyzer = analyzer ?? RuuviAnalyzer(),
        super(const RuuviState()) {
    ServiceAdapter.instance()?.setRuuviBloc(this);
    on<RuuviDataReceived>(_onDataReceived);
    on<ClearHistory>(_onClearHistory);
  }

  void _onDataReceived(
      RuuviDataReceived event,
      Emitter<RuuviState> emit,
      ) {
    final data = event.data;

    final tags = Map<String, RuuviData>.from(state.tags);
    tags[data.id] = data;

    var history = state.history;
    var analysis = state.analysis;

    if (data.temperature != null &&
        data.humidity != null &&
        data.pressure != null &&
        data.batteryVoltage != null) {
      // final sample = RuuviSample(
      //   timestamp: data.lastSeen,
      //   temperature: data.temperature!,
      //   humidity: data.humidity!,
      //   pressure: data.pressure!,
      //   battery: data.batteryVoltage!,
      // );

      //history = List<RuuviSample>.from(history)..add(sample);
      history = ServiceAdapter.instance()?.getSamples()??[];

      if (history.length > RuuviThresholds.maxSamples) {
        history = history.sublist(
          history.length - RuuviThresholds.maxSamples,
        );
      }

      final shouldAnalyze = analysis == null ||
          DateTime.now().difference(analysis.analyzedAt).inSeconds >=
              RuuviThresholds.analysisIntervalSec;

      if (shouldAnalyze) {
        analysis = _analyzer.analyze(history);
      }
    }

    emit(state.copyWith(
      tags: tags,
      history: history,
      analysis: analysis,
    ));

  }

  void _onClearHistory(
      ClearHistory event,
      Emitter<RuuviState> emit,
      ) {
    emit(state.copyWith(
      history: const [],
      clearAnalysis: true,
    ));
  }
}
