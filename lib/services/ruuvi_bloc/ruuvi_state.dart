import 'package:equatable/equatable.dart';
import '../../models/ruuvi_analysis.dart';
import '../../models/ruuvi_data.dart';
import '../../models/ruuvi_sample.dart';

class RuuviState extends Equatable {
  final Map<String, RuuviData> tags;
  final List<RuuviSample> history;
  final RuuviAnalysis? analysis;
  final String? errorMessage;

  const RuuviState({
    this.tags = const {},
    this.history = const [],
    this.analysis,
    this.errorMessage,
  });

  List<RuuviData> get sortedTags {
    final list = tags.values.toList()
      ..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
    return list;
  }

  RuuviState copyWith({
    Map<String, RuuviData>? tags,
    List<RuuviSample>? history,
    RuuviAnalysis? analysis,
    String? errorMessage,
    bool clearError = false,
    bool clearAnalysis = false,
  }) {
    return RuuviState(
      tags: tags ?? this.tags,
      history: history ?? this.history,
      analysis: clearAnalysis ? null : (analysis ?? this.analysis),
      errorMessage:
      clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [tags, history, analysis, errorMessage];
}