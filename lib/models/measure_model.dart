class MeasureModel {
  final String id;
  final String measureType;

  MeasureModel({required this.id, required this.measureType,});

  Map<String, dynamic> toJson() {
    return {
      'device': id,
      'measure': measureType,
    };
  }
}
