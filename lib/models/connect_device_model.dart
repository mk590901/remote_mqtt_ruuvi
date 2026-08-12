class ConnectDeviceModel {
  final String id;

  ConnectDeviceModel({required this.id,});

  Map<String, dynamic> toJson() {
    return {
      'connect': id
    };
  }
}
