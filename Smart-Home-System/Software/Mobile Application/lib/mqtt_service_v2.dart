// mqtt_service_v2.dart
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'base_mqtt_service.dart';

class MQTTServiceV2 implements BaseMQTTService {
  MqttServerClient? _client;
  Function(String, String)? onMessageCallback;

  // Connect to the MQTT broker
  Future<bool> connect({required String username, required String password}) async {
    _client = MqttServerClient.withPort(
        '7723500f166547509bc34df058860232.s1.eu.hivemq.cloud',
        'FlutterClient',
        8883
    ); // Updated URL
    _client!.secure = true;
    _client!.logging(on: true);
    _client!.keepAlivePeriod = 20;
    _client!.onConnected = onConnected;
    _client!.onDisconnected = onDisconnected;
    _client!.onSubscribed = onSubscribed;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('FlutterClientV2')
        .startClean()
        .authenticateAs(username, password)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMessage;

    try {
      await _client!.connect();
    } catch (e) {
      print('Exception: $e');
      _client?.disconnect();
      return false;
    }

    if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
      print('MQTT connected');
      return true;
    } else {
      print('MQTT connection failed - status is ${_client!.connectionStatus}');
      return false;
    }
  }

  void onConnected() => print('Connected to MQTT broker V2');

  void onDisconnected() => print('Disconnected from MQTT broker V2');

  void onSubscribed(String topic) => print('Subscribed to topic: $topic');

  void subscribeToTopic(String topic, Function(String, String) onMessage) {
    if (_client == null) {
      print('MQTT client is not connected');
      return;
    }
    onMessageCallback = onMessage;
    _client!.subscribe(topic, MqttQos.atLeastOnce);
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> event) {
      final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      if (onMessageCallback != null) {
        onMessageCallback!(event[0].topic, payload);
      }
    });
  }

  void publishMessage(String topic, String message) {
    if (_client == null) {
      print('MQTT client is not connected');
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void disconnect() {
    if (_client == null) {
      print('MQTT client is already disconnected or was never connected.');
      return;
    }
    _client!.disconnect();
  }

  MqttServerClient? get client => _client;
}
