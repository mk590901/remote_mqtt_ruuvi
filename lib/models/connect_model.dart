class ConnectModel {
  final String device;
  final String topic;
  final int    survey;

  ConnectModel({required this.device, required this.topic, required this.survey});

  Map<String, dynamic> toJson() {
    return {
      'connect': device, 'topic': topic, 'survey': survey,
    };
  }
}
