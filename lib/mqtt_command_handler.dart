import 'dart:async';

typedef OnTimeoutCallback = void Function();
typedef OnResponseCallback = void Function(String responseData);

class MqttCommandHandler {
  final Duration timeoutDuration;

  Timer? _timeoutTimer;
  OnTimeoutCallback? onTimeout;
  OnResponseCallback? onResponse;
  OnResponseCallback? onDataReceived;

  late String lastAction = '';

  MqttCommandHandler({
    this.timeoutDuration = const Duration(seconds: 5),
    this.onTimeout,
    this.onResponse,
    this.onDataReceived,
  });

  /// Called when publish
  void sendCommand({
    required String action,
    // Can add any other parameters here
  }) {
    // Store last command
    lastAction = action;
    // 1. Cancel the previous timer (important for frequent sending)
    _timeoutTimer?.cancel();

    // 2. Send also a command via MQTT client
    // mqttClient.publish(topic: topic, payload: payload);
    print('The command has been sent: $lastAction');

    // 3. Start a new timer only for this command
    _timeoutTimer = Timer(timeoutDuration, () {
      onTimeout?.call();
      _timeoutTimer = null;
    });
  }

  /// Called from the MQTT callback when a response arrives.
  void handleResponse(final String jsonString) {
    // If the timer has already been cancelled or has triggered, ignore it.
    // Or maybe this is asynchronic answer...

    print ("handleResponse._timeoutTimer=$_timeoutTimer");
    if (_timeoutTimer == null) {
      onDataReceived?.call(jsonString);
      return;
    }

    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    onResponse?.call(jsonString);
  }

  /// Force cancellation of the wait (e.g. on disconnection)
  void cancelPending() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  /// Can use If need to know if currently waiting for an answer
  bool get isWaiting => _timeoutTimer?.isActive ?? false;
}