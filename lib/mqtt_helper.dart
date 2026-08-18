import 'dart:async';
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';
import 'gui_adapter/service_adapter.dart';
import 'mqtt_command_handler.dart';
import '../utils.dart';

class MqttHelper {
  MqttServerClient? client;
  static final String _server = 'broker.hivemq.com';
  //static final String _server = 'public.mqtthq.com';
  //static final String _server = 'mqtt.flespi.io';
  //static final String _server = 'broker.emqx.io';
  static final String _flutterClient = 'flutter_client_${const Uuid().v4()}';
  static final String _out_topic = 'ble_inp/topic';
  static final String _inp_topic = 'ble_out/topic';

  Timer? _reconnectTimer;
  MqttCommandHandler? _commandHandler;

  void start() async {
    print('MqttHelper started');
    await initializeMqttClient();
  }

  Future<void> initializeMqttClient() async {

    _commandHandler = MqttCommandHandler(
      timeoutDuration: const Duration(seconds: 5),
      onTimeout: () {
        print('Timeout');
        ServiceAdapter.instance()?.setError("Timeout for ${_commandHandler?.lastAction}");
      },
      onResponse: (data) {
        answerAnalysis(data);
      },
      onDataReceived: (data) {
        updateData(data);
      },

    );

    ServiceAdapter.instance()?.setProgress(true);

    client = MqttServerClient(_server, _flutterClient);
    client?.logging(on: false); //  true
    client?.setProtocolV311();
    client?.connectTimeoutPeriod = 2000;
    client?.keepAlivePeriod = 20;
    client?.onDisconnected = onDisconnected;
    client?.onConnected = onConnected;
    client?.onSubscribed = onSubscribed;
    client?.onUnsubscribed = onUnsubscribed;
    client?.autoReconnect = false;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(_flutterClient)
        .startClean();
    client?.connectionMessage = connMess;

    try {
      await client?.connect();
    } catch (e) {
      print('Connection failed: $e');
      client?.disconnect();
      ServiceAdapter.instance()?.setProgress(false);
      scheduleReconnect();
    }

    // Subscribe to topic
    if (client?.connectionStatus!.state == MqttConnectionState.connected) {
      client?.subscribe(_inp_topic, MqttQos.atLeastOnce);
      client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final recMessage = c[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(
            recMessage.payload.message);
        //print('Received message: $payload from topic: ${c[0].topic}');
        _commandHandler?.handleResponse(payload);
      });
    }
  }

  void scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () async {
      print('******* Attempting to reconnect... *******');
      await initializeMqttClient();
    });
  }

  void onConnected() {
    print('******* onConnected: onConnectedConnected to MQTT broker  $_server *******');
    print ("onConnected: connected->${isConnected()}, subscribed->${isSubscribed()}");
    showState();

    //queue.add({'response': 'Connected', 'value': 'Connected to MQTT broker $_server',});



    // connected  ? ServiceAdapter.instance()?.mqttConnect() : ServiceAdapter.instance()?.mqttDisconnect();
    // subscribed ? ServiceAdapter.instance()?.mqttSubscribe() : ServiceAdapter.instance()?.mqttUnsubscribe();

  }

  void showState() {
    bool connected = isConnected();
    bool subscribed = isSubscribed();

    connected  ? ServiceAdapter.instance()?.mqttConnect() : ServiceAdapter.instance()?.mqttDisconnect();
    subscribed ? ServiceAdapter.instance()?.mqttSubscribe() : ServiceAdapter.instance()?.mqttUnsubscribe();
    if (connected && subscribed) {
      ServiceAdapter.instance()?.setProgress(false);
    }

  }

  void onDisconnected() {
    print('******* onDisconnected: Disconnected from MQTT broker $_server *******');
    print ("onDisconnected: connected->${isConnected()}, subscribed->${isSubscribed()}");
    showState();
    // queue.add({'response': 'Disconnected', 'value': 'Disconnected from MQTT broker $_server',});
    // queue.add({'response': 'progress', 'value': false });
    ServiceAdapter.instance()?.setProgress(false);

    destroyStateMachine();
    // if (_serviceStopped) {
    //   return;
    // }
    scheduleReconnect();
  }

  void onSubscribed(String topic) {
    print('******* onSubscribed to topic: $topic *******');
    print ("onSubscribed: connected->${isConnected()}, subscribed->${isSubscribed()}");
    showState();
    //queue.add({'response': 'Subscribed', 'value': 'Subscribed to topic: $topic'});
    createStateMachine();
  }

  void createStateMachine() {
    // helper = Client_connectHelper();
    // helper?.setDeviceName(_deviceId);
    // helper?.setTopicName(_inp_topic);
    // helper?.init();
    // print ("Create and init state machine");
    //@helper?.run('Connect');
  }

  void destroyStateMachine() {
    // helper?.dispose();
    // helper = null;
    print ("Destroy state machine");
  }

  void onUnsubscribed(String? topic) {
    print('***!*** onUnsubscribed from topic: $topic ***!***');
    print ("onUnsubscribed: connected->${isConnected()}, subscribed->${isSubscribed()}");
    //queue.add({'response': 'Unsubscribed', 'value': 'Unsubscribed from topic: $topic'});
    showState();
    destroyStateMachine();
    client?.disconnect();
    scheduleReconnect();
  }

  bool isSubscribed() {
    if (!isConnected()) {
      return false;
    }
    MqttSubscriptionStatus? status = client?.getSubscriptionsStatus(_inp_topic);
    if (status == null) {
      return false;
    }
    bool result =  (status == MqttSubscriptionStatus.active) ? true : false;
    return result;
  }

  bool isConnected() {
    return (client?.connectionStatus?.state == MqttConnectionState.connected) ? true : false;
  }

  void sendCommand(final String jsonString) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonString);
    try {
      client?.publishMessage(_out_topic, MqttQos.atMostOnce, builder.payload!);
    }
    catch (exception) {
      print ('Publish - error');
    }

  }

  void sendData (final String command, final String jsonString) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(jsonString);
    try {
      client?.publishMessage(_out_topic, MqttQos.atMostOnce, builder.payload!);
      _commandHandler?.sendCommand (action: command);
    }
    catch (exception) {
      print ('Publish - error');
    }
    //@print ('PUBLISH WAS DONE');
  }

  void sendData2 (dynamic data) {
    print('onDataReceived called with data: $data');
    if (data is Map && data.containsKey('command') &&  data.containsKey('data')) {
      final String command = data['command'] as String;
      final String receivedData = data['data'] as String;
      print('Service received: $command:($receivedData)');

      if (command == 'publicKey') {
        //helper?.run('PublicKey');
      }

      if (command == 'pong') {
        //helper?.resetPings();
      }

      if (command == 'phone_id') {
        //_deviceId = receivedData;
        //print ('DEVICE->$_deviceId');
      }

      if (command == 'color' || command == 'stop' || command == 'break'
          || command == 'request' || command == 'connect' || command == 'publicKey') {
        String jsonString = receivedData;
        final builder = MqttClientPayloadBuilder();
        builder.addString(jsonString);
        try {
          client?.publishMessage(_out_topic, MqttQos.atMostOnce, builder.payload!);
        }
        catch (exception) {
          print ('Publish - error');
        }
        //@print ('PUBLISH WAS DONE');
      }
    }
    else {
      print('Invalid data format: $data');
    }
  }

  void dispose() {
    client?.disconnect();
  }

  void answerAnalysis(String jsonString) {
    print ("answerAnalysis->$jsonString");
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    if (map.containsKey('ack')) {
      String command = map['ack'];
      print ('ack->[$command]');
      switch (command) {
        case 'sync'    :
          String transmitterMac = map['transmitter_mac'];
          String transmitterName = map['transmitter_type'];

          print ('sync [$transmitterMac,$transmitterName]');

          ServiceAdapter.instance()?.ackSync(map["session"]??false, map["scan"]??false);
          ServiceAdapter.instance()?.updateTransmitterInfo(transmitterName, transmitterMac);

          break;

        case 'start-session' :

          String transmitterMac = map['transmitter_mac'];
          String transmitterName = map['transmitter_type'];

          print ('start-session [$transmitterMac,$transmitterName]');

          ServiceAdapter.instance()?.ackStartSession();
          ServiceAdapter.instance()?.updateTransmitterInfo(transmitterName, transmitterMac);

          break;
        case 'final-session' :
          ServiceAdapter.instance()?.ackFinalScan();
          ServiceAdapter.instance()?.updateBleDeviceInfo('-', 0, '-', false);
          ServiceAdapter.instance()?.ackFinalSession();
          ServiceAdapter.instance()?.updateTransmitterInfo('-', '-');
          break;
        case 'start-scan' :

          String transmitterMac = map['transmitter_mac'];
          String transmitterName = map['transmitter_type'];

          print ('start-scan [$transmitterMac,$transmitterName]');

          ServiceAdapter.instance()?.ackStartScan();
          break;
        case 'final-scan' :

          print ("******* final-scan *******");

          ServiceAdapter.instance()?.ackFinalScan();
          ServiceAdapter.instance()?.updateBleDeviceInfo('-', 0, '-', true);

          break;
        default:;
      }
    }
  }

  void updateData(String jsonString) {
    String? time;
    String? bleMac;
    String? transmitterMac;
    String? transmitterName;
    String? state;
    String? measureType;
    String? value;
    String? units;
    bool?   online;
    int?    rssi;

    if (jsonString.isEmpty) {
      print ("updateData->[$jsonString]: jsonString isEmpty -- ignore processing");
      return;
    }

    //print ("updateData->$jsonString");
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    if (map.containsKey('error')) {
      String? errorMessage = map['error'];
      ServiceAdapter.instance()?.setError(errorMessage??'?');
      String? bleName = map['ble_name'];
      ServiceAdapter.instance()?.setBleDevice(bleName??'?');
      if (bleName != ServiceAdapter.instance()?.getDeviceName()) {
        print ("Invalid selection [$bleName][${ServiceAdapter.instance()?.getDeviceName()}]");
        ServiceAdapter.instance()?.forceBleDeviceSelection(bleName);
      }
      return;
    }

    time        = map['time'];
    rssi        = map['rssi'];
    bleMac      = map['ble_mac'];
    online      = map['online'];  //  ??
    state       = map['state'];
    measureType = "Temp";//map['measure'];
    value       = _formatDouble(map["temperature"]);//map['value'];
    units       = "°C";//map['units'];

    String prompt = value == null ? '' : value.isEmpty? '' : measureType??'';
    String mvv   = isMeasureError(value) ? value??'' : "${value??''} ${units??''}";
    String mv = prompt.isEmpty ? mvv : "$prompt: $mvv";

    ServiceAdapter.instance()?.updateBleDeviceInfo(bleMac, rssi, time, online);

    transmitterMac = map['transmitter_mac'];
    transmitterName = map['transmitter_type'];

    //print ('updateData [$transmitterMac,$transmitterName]');

    ServiceAdapter.instance()?.updateTransmitterInfo(transmitterName??'', transmitterMac??'');

    //print ('updateData.state [$state,$measureType,$mv]');

    ServiceAdapter.instance()?.updateAppState(state??'', measureType??'', mv.trim());

    if (time != null) {
      ServiceAdapter.instance()?.updateTraceInfo(map);
    }




  }

  String _formatDouble(dynamic value, [int fractionDigits = 2]) {
    if (value is String) {
      return value;
    }
    if (value == null) return '—';
    final numValue = value as num?;
    if (numValue == null) return '—';
    return numValue.toStringAsFixed(fractionDigits);
  }

}
