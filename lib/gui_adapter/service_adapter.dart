import 'dart:convert';
//import 'dart:async';
import 'package:intl/intl.dart';
import '../models/command_model.dart';
import '../models/discovery_model.dart';
import '../models/measure_model.dart';
import '../models/ruuvi_data.dart';
import '../models/ruuvi_sample.dart';
import '../models/connect_device_model.dart';
import '../models/disconnect_device_model.dart';
import '../models/trace.dart';
//import '../models/circular_buffer.dart';
import '../models/fixed_buffer.dart';
import '../models/trace_db.dart';
import '../ui_blocs/app_bloc.dart';
import '../ui_blocs/mqtt_bloc.dart';
import '../ui_blocs/remote_ble_bloc.dart';
import '../ui_blocs/list_bloc.dart';
import '../mqtt_helper.dart';
import '../health_dashboard/health_ai_model.dart';
import '../health_dashboard/bloc/health_bloc.dart';
//import '../health_dashboard/bloc/health_event.dart';
import '../services/ruuvi_bloc/ruuvi_bloc.dart';
import '../services/ruuvi_bloc/ruuvi_event.dart';
import '../services/ruuvi_analyzer.dart';
import '../models/ruuvi_analysis.dart';

final int BUFFER_SIZE = 256;

class ServiceAdapter {
  static ServiceAdapter? _instance;

  final List<Trace>   traces = [];

  late AppBloc?       _appBloc;
  late MqttBloc?      _mqttBloc;
  late ListBloc?      _listBloc;
  late RemoteBleBloc? _bleBloc;
  late RuuviBloc?     _ruuviBloc = null;
  late HealthBloc?    _healthBloc = null;
  late String         _deviceName = '';
  late MqttHelper?    _mqtt_helper;

  late String _appName = 'Unknown';
  late String _packageName = 'Unknown';
  late String _version = 'Unknown';
  late String _buildNumber = 'Unknown';
  late String _buildSignature = 'Unknown';
  late String _installerStore = 'Unknown';
  late String _platform = 'Unknown';

  List<RawHealthRecord> _rawRecords = [];
  List<RawHealthRecord> _localRawRecords = [];
  List<TraceDb> _allData = [];
  List<TraceDb> _incomingData = [];

  //CircularBuffer<RuuviSample> buffer_ = CircularBuffer<RuuviSample>(BUFFER_SIZE+1);
  FixedBuffer<RuuviSample> buffer_ = FixedBuffer<RuuviSample>(BUFFER_SIZE);

  static void initInstance() {
    _instance ??= ServiceAdapter();
    print ('ServiceAdapter.initInstance -- Ok');
  }

  ServiceAdapter() {
    _mqtt_helper = MqttHelper();
    print ("_mqtt_helper was create");
  }

  static ServiceAdapter? instance() {
    if (_instance == null) {
      throw Exception("--- ServiceAdapter was not initialized ---");
    }
    return _instance;
  }

  void setDeviceName(String deviceName) {
    _deviceName = deviceName;
  }

  String getDeviceName() {
    return _deviceName;
  }

  void setRawHRecords(List<TraceDb> traceDB) {
    _allData = traceDB;
    print ("******* setRawHRecords._allData [${_allData.length}] *******");
    // _rawRecords = fetchRawRecords(traceDB);
    // print ("******* setRawHRecords._rawRecords [${_rawRecords.length}] *******");
  }

  List<TraceDb> getAllData() {
    return _allData;
  }

  List<RawHealthRecord> getRawHRecords() {
    return _rawRecords;
  }

  List<RawHealthRecord> getLocalRawHRecords() {
    return _localRawRecords;
  }

  void updateIncomingData(TraceDb traceDB) {
    _incomingData.add(traceDB);
    print ("******* updateIncomingData._incomingData-> [${_incomingData.length}] *******");
    _localRawRecords = fetchRawRecords(_incomingData);
    print ("******* updateIncomingData._localRawRecords-> [${_localRawRecords.length}] *******");
  }


  void setHealthBloc(HealthBloc? healthBloc) {
    _healthBloc = healthBloc;
  }

  void setAppBloc(AppBloc? appBloc) {
    _appBloc = appBloc;
  }

  void setMQTTBloc(MqttBloc? mqttBloc) {
    _mqttBloc = mqttBloc;
  }

  void setListBloc(ListBloc? listBloc) {
    _listBloc = listBloc;
  }

  void setRuuviBloc(RuuviBloc? ruuviBloc) {
    _ruuviBloc = ruuviBloc;
  }

  void setBleBloc(RemoteBleBloc? bleBloc) {
    _bleBloc = bleBloc;
  }

  void mqttInit() {
    _mqtt_helper?.initializeMqttClient();
  }

  void mqttDispose() {
    _mqtt_helper?.dispose();
  }

  void mqttConnect() {
    _mqttBloc?.add(MqttEvent.connect);
  }

  void mqttSubscribe() {
    _mqttBloc?.add(MqttEvent.subscribe);
  }

  void mqttUnsubscribe() {
    _mqttBloc?.add(MqttEvent.unsubscribe);
  }

  void mqttDisconnect() {
    _mqttBloc?.add(MqttEvent.disconnect);
  }

  void setDiscoveryDeviceName(final String deviceName) {
    print ("setDiscoveryDeviceName->[$deviceName]");
    _bleBloc?.add(SelectDevice(deviceName));
  }

  void start() {
    print ('------- ServiceAdapter.start -------');
  }

  void stop() {
    print ('------- ServiceAdapter.stop -------');
  }

  void setProgress(bool progress) {
    _mqttBloc?.add(InProgressEvent(progress));
    //@print ('******* setProgress $progress ******* ${DateTime.now()}');
  }

  void sendCommand(final String action, final String entity) {
    final Command command = Command(command: action, data: entity);
    String jsonString = jsonEncode(command.toJson());
    _mqtt_helper?.sendData(action, jsonString);
  }

  void setError(final String message) {
    _bleBloc?.add(SetError(message));
  }

  void setBleDevice(final String device) {
    _bleBloc?.add(SelectDevice(device));
  }

  // void stopEsp32() {
  //   final Command command = Command(command: "stop", data: "");
  //   String jsonString = jsonEncode(command.toJson());
  // }

  void ackSync(bool session, bool scan) {
    _bleBloc?.add(ConfirmSync(session, scan));
  }

  void ackStartSession() {
    _bleBloc?.add(ConfirmStartSession());
  }

  void ackFinalSession() {
    _bleBloc?.add(ConfirmFinalSession());
  }

  void ackStartScan() {
    _bleBloc?.add(ConfirmStartScan());
  }

  void ackFinalScan() {
    _bleBloc?.add(ConfirmFinalScan());
  }

  void updateTransmitterInfo(final String name, final String mac) {
    print('updateTransmitterInfo [$name, $mac]');
    _bleBloc?.add(UpdateTransmitter(name, mac));
  }

  void updateAppState(final String state, final String measureType, final String value) {
    print('updateAppState [$state, $measureType, ($value)]');
    _bleBloc?.add(UpdateState(state, measureType, value.isEmpty ? null : value));
  }

  void updateBleDeviceInfo(String? bleMac, int? rssi, String? time, bool? online) {
    _bleBloc?.add(UpdateBleDevice(bleMac, rssi, time, online));
  }

  void updateTraceInfo(Map<String,dynamic> map) {

    print ("updateTraceInfo $map");

    // double? ax =  map["accel-x"]??0;
    // double? ay =  map["accel-y"]??0;
    // double? az =  map["accel-z"]??0;
    //
    // double? accelX = (ax == -32768) ? null : ax! / 1000.0;
    // double? accelY = (ay == -32768) ? null : ay! / 1000.0;
    // double? accelZ = (az == -32768) ? null : az! / 1000.0;

    double? accelX = map["accel-x"];
    double? accelY = map["accel-y"];
    double? accelZ = map["accel-z"];

    RuuviOrientation orientation = RuuviData.detectOrientation(
      accelX: accelX,
      accelY: accelY,
      accelZ: accelZ,
    );

    RuuviData ruuviData = RuuviData(
      id:               map["ble_mac"], //  Ble_name
      mac:              map["ble_mac"],
      temperature:      map["temperature"],
      humidity:         map["humidity"],
      pressure:         map["pressure"],
      accelX:           accelX, //map["accel-x"],
      accelY:           accelY, //map["accel-y"],
      accelZ:           accelZ, //map["accel-z"],
      batteryVoltage:   map["battery-voltage"],
      txPower:          map["tx-power"],
      movementCounter:  map["movement-counter"],
      sequence:         map["sequence"],
      rssi:             map["rssi"],
      lastSeen:         parseCustomDate(map["time"]),
      orientation:      orientation,
    );



    // RuuviOrientation orientation = RuuviData.detectOrientation(
    //   accelX: ruuviData.accelX,
    //   accelY: ruuviData.accelY,
    //   accelZ: ruuviData.accelZ
    // );

    //print ("Orientation: $orientation");
    RuuviSample ruuviSample = ruuviData.ruuviSample();
    buffer_.put(ruuviSample);
    print ("******* buffer.size: ${buffer_.length} *******");
    RuuviAnalyzer analyzer = RuuviAnalyzer();
    List<RuuviSample> samples = buffer_.getList();
    print ("******* samples.size: ${samples.length} *******");
    RuuviAnalysis analysis = analyzer.analyze(samples);
    analysis.trace();

    _ruuviBloc?.add(RuuviDataReceived(ruuviData));

    int x = 0;
    int y = x;
  }

  List<RuuviSample> getSamples() {
    return buffer_.getList();
  }

  DateTime parseCustomDate(String dateStr) {
    // DataTime string format:
    final format = DateFormat('yyyy/MM/dd HH:mm:ss.SSS');
    return format.parse(dateStr);
  }

  void breakEsp32() {
    final Command command = Command(command: "break", data: "");
    String jsonString = jsonEncode(command.toJson());
    //@FlutterForegroundTask.sendData({'command': 'break', 'data': jsonString});
  }

  void sendDiscoveryRequest(String request) {
    final DiscoveryDeviceModel commandRequest = DiscoveryDeviceModel(request: request);
    String jsonString = jsonEncode(commandRequest.toJson());
    print ('sendDiscoveryRequest->$jsonString');
  }

  void sendConnectRequest(String deviceId) {
    final ConnectDeviceModel commandRequest = ConnectDeviceModel(id: deviceId);
    String jsonString = jsonEncode(commandRequest.toJson());
    print ('sendConnectRequest->$jsonString');
  }

  void sendDisconnectRequest(String deviceId) {
    final DisconnectDeviceModel commandRequest = DisconnectDeviceModel(id: deviceId);
    String jsonString = jsonEncode(commandRequest.toJson());
    print ('sendDisconnectRequest->$jsonString');
  }

  void sendMeasureRequest(String deviceId, String measureType) {
    final MeasureModel commandRequest = MeasureModel(id: deviceId, measureType: measureType);
    String jsonString = jsonEncode(commandRequest.toJson());
    print ('sendMeasureRequest->$jsonString');
    //@FlutterForegroundTask.sendData({'command': 'request', 'data': jsonString});
  }

  void sendEncryptedRequest(String request) {

    // RSAPublicKey publicKey = _server.publicKey;
    // print ("sendEncryptedRequest.publicKey->[${publicKey.toString()}]");
    //
    // XorClient xorClient = XorClient();
    // xorClient.setKey(publicKey);
    // XorPacket packet = xorClient.encrypt(_server.id, request);
    // print ("packet->\n${packet.toJsonString()}");
    // FlutterForegroundTask.sendData({'command': 'request', 'data': packet.toJsonString()});

    final DiscoveryDeviceModel commandRequest = DiscoveryDeviceModel(request: request);
    String jsonString = jsonEncode(commandRequest.toJson());
    print ('sendRequest->$jsonString');
    //@FlutterForegroundTask.sendData({'command': 'request', 'data': jsonString});

  }

  void executeCommand(String jsonString) {
    Command command = Command.fromJsonString(jsonString);
    print ('executeCommand->[${command.command}]');
  }

  // void updateWeather(String jsonString) {
  //   print ('updateWeather->[$jsonString]');
  //   //showJson(jsonString);
  // }

  void forceBleDeviceSelection(String? deviceName) {
    if (deviceName != null) {
      _listBloc?.add(SelectOptionEvent(deviceName));
    }
  }

  void startScan() {
    _bleBloc?.add(StartScan());
  }

  void stopScan() {
    _bleBloc?.add(FinalScan());
  }

  void setAppInfo(String platform, String appName, String packageName, String version, String buildNumber, String buildSignature, String installerStore) {
    _appName = appName;
    _packageName = packageName;
    _version = version;
    _buildNumber = buildNumber;
    _buildSignature = buildSignature;
    _installerStore = installerStore;
    _platform = platform;
  }

  String appName() {
    return _appName;
  }

  String appVersion() {
    return _version;
  }

  String appSignature() {
    return _buildSignature;
  }

  String platform() {
    return _platform;
  }


  void updatePong(String jsonString) {
    print ('updatePong->[$jsonString]');
    //@FlutterForegroundTask.sendData({'command': 'pong', 'data': jsonString});
  }

  // void updatePacket(String jsonString) {
  //   print ('updatePacket->[$jsonString]');
  //   RSAPrivateKey privateKey = _server.clientPrivateKey;
  //   XorServer xorServer = XorServer();
  //   xorServer.setKey(privateKey);
  //   XorPacket packet = XorPacket.fromJsonString(jsonString);
  //   String? restoreToJson = xorServer.decrypt(packet);
  //   print ("restoreTJson->\n[$restoreToJson]");
  //   showJson(restoreToJson?? '');
  // }

  // void updatePublicKey(String jsonString) {
  //   RSAPublicKey publicKey = RSAPublicKey.fromJsonString(jsonString);
  //   print ('updatePublicKey->${publicKey.toString()}');
  //   _server = Server(_deviceName, publicKey); //  Server was created
  //   _server.createKeys();
  //   String jsonPublicKey = _server.responsePublicKey();
  //   print ('publicKey to server->$jsonPublicKey');
  //   // Create packet for send public key to server
  //   FlutterForegroundTask.sendData({'command': 'publicKey', 'data': jsonPublicKey});
  // }

  // void showJson(final String jsonString) {
  //   try {
  //     final Map<String,dynamic> map = jsonDecode(jsonString);
  //     map.forEach((key, value) {
  //       _listBloc?.add(AddItemEvent("$key : $value"));
  //     });
  //   }
  //   catch(e) {
  //   }
  // }

  bool isMQTTOk() {
    bool connected = _mqtt_helper?.isConnected()?? false;
    bool subscribed = _mqtt_helper?.isSubscribed()?? false;
    return connected && subscribed;
  }

}
