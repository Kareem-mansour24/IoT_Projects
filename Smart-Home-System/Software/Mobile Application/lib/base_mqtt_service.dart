abstract class BaseMQTTService {
  Future<bool> connect({required String username, required String password});
  void subscribeToTopic(String topic, Function(String, String) onMessage);
  void publishMessage(String topic, String message);
  void disconnect();
}
