class DiscoveryDeviceModel {
  final String request;

  DiscoveryDeviceModel({required this.request,});

  Map<String, dynamic> toJson() {
    return {
      'discovery': request
    };
  }
}
