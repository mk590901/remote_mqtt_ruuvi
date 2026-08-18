import '../health_ai_model.dart';

// lib/ruuvi_bloc/health_state.dart
class HealthState {
  final HealthAIModel model;
  final Map<String, dynamic> analysis;
  final bool isLoading;

  HealthState({
    required this.model,
    required this.analysis,
    this.isLoading = false,
  });

  HealthState copyWith({
    HealthAIModel? model,
    Map<String, dynamic>? analysis,
    bool? isLoading,
  }) {
    return HealthState(
      model: model ?? this.model,
      analysis: analysis ?? this.analysis,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
