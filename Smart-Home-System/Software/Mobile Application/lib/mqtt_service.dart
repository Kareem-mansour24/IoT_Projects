// mqtt_service.dart
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'base_mqtt_service.dart';

class MQTTService implements BaseMQTTService {
  MqttServerClient? _client;
  Function(String, String)? onMessageCallback;

  // Connect to the MQTT broker
  Future<bool> connect({required String username, required String password}) async {
    _client = MqttServerClient.withPort(
      '836d265158fe407b82c0c60afc009fad.s1.eu.hivemq.cloud',
      'FlutterClient',
      8883,
    );
    _client!.secure = true;
    _client!.logging(on: true);
    _client!.keepAlivePeriod = 20;
    _client!.onConnected = onConnected;
    _client!.onDisconnected = onDisconnected;
    _client!.onSubscribed = onSubscribed;

    // Set up secure settings if required (add certificates if needed)
    // _client!.securityContext = SecurityContext.defaultContext; // Customize with your certificates if needed

    // Set up the connection message
    final connMessage = MqttConnectMessage()
        .withClientIdentifier('FlutterClient')
        .startClean()
        .authenticateAs(username, password)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .withWillQos(MqttQos.atLeastOnce);
    _client!.connectionMessage = connMessage;

    try {
      print('Connecting to MQTT broker...');
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
      _client?.disconnect();
      return false;
    }
  }

  void onConnected() {
    print('Connected to MQTT broker');
  }

  void onDisconnected() {
    print('Disconnected from MQTT broker');
  }

  void onSubscribed(String topic) {
    print('Subscribed to topic: $topic');
  }

  // Subscribe to a topic
  void subscribeToTopic(String topic, Function(String, String) onMessage) {
    if (_client == null || _client!.connectionStatus?.state != MqttConnectionState.connected) {
      print('MQTT client is not connected');
      return;
    }
    onMessageCallback = onMessage;
    _client!.subscribe(topic, MqttQos.atLeastOnce);
    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> event) {
      final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('Received message: $payload from topic: ${event[0].topic}');
      if (onMessageCallback != null) {
        onMessageCallback!(event[0].topic, payload);
      }
    });
  }

  // Publish a message to a topic
  void publishMessage(String topic, String message) {
    if (_client == null || _client!.connectionStatus?.state != MqttConnectionState.connected) {
      print('MQTT client is not connected');
      return;
    }
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  // Disconnect the MQTT client safely
  void disconnect() {
    if (_client == null || _client!.connectionStatus?.state != MqttConnectionState.connected) {
      print('MQTT client is already disconnected or was never connected.');
      return;
    }
    _client!.disconnect();
  }

  MqttServerClient? get client => _client; // Getter to access the client
}