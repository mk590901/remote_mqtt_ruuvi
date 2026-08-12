class DisconnectDeviceModel {
  final String id;

  DisconnectDeviceModel({required this.id,});

  Map<String, dynamic> toJson() {
    return {
      'disconnect': id
    };
  }
}
