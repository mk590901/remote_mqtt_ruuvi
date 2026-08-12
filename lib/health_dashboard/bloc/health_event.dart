import '../health_ai_model.dart';

// lib/bloc/health_event.dart
abstract class HealthEvent {}

class LoadHealthData extends HealthEvent {}

class AddRawRecord extends HealthEvent {
  // final RawHealthRecord record;
  // AddRawRecord(this.record);
}

class RefreshAnalysis extends HealthEvent {}