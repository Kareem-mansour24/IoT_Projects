// fan.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mqtt_service_v2.dart'; // Use the correct MQTT service implementation

class FanControlPage extends StatefulWidget {
  @override
  _FanControlPageState createState() => _FanControlPageState();
}

class _FanControlPageState extends State<FanControlPage> {
  final MQTTServiceV2 mqttService = MQTTServiceV2();
  double _fanSpeedValue = 1; // Default fan speed (Medium)
  bool isFanOn = false;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToMQTT(); // Connect to MQTT broker on initialization
  }

  // Connect to MQTT broker and handle connection status
  Future<void> _connectToMQTT() async {
    isConnected = await mqttService.connect(
      username: 'faresmohamed260',
      password: '#Rmc136a1drd47r',
    );
    setState(() {
      if (!isConnected) {
        _showStatusDialog(
          'MQTT Connection Failed',
          'Could not connect to the MQTT broker.',
          isError: true,
        );
      } else {
        _subscribeToTopics(); // Subscribe to fan state topics after successful connection
      }
    });
  }

  // Subscribe to relevant MQTT topics
  void _subscribeToTopics() {
    mqttService.subscribeToTopic('fan_state_topic', _onMessageReceived);
    mqttService.subscribeToTopic('fan_speed', _onMessageReceived);
  }

  // Handle incoming messages from MQTT
  void _onMessageReceived(String topic, String message) {
    print('Received message: $message from topic: $topic');
    setState(() {
      if (topic == 'fan_state_topic') {
        isFanOn = message.toLowerCase() == 'on'; // Update fan status
      } else if (topic == 'fan_speed') {
        // Update fan speed based on received message
        switch (message.toUpperCase()) {
          case 'LOW':
            _fanSpeedValue = 0;
            break;
          case 'MEDIUM':
            _fanSpeedValue = 1;
            break;
          case 'HIGH':
            _fanSpeedValue = 2;
            break;
        }
      }
    });
  }

  // Toggle fan on/off and publish the state to MQTT
  void _toggleFan() {
    setState(() {
      isFanOn = !isFanOn;
      mqttService.publishMessage('fan_state_topic', isFanOn ? 'ON' : 'OFF');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFanOn ? 'Fan turned ON' : 'Fan turned OFF'),
          backgroundColor: isFanOn ? Colors.green : Colors.red,
        ),
      );
    });
  }

  // Change fan speed and publish the new speed to MQTT
  void _changeFanSpeed(double speed) {
    setState(() {
      _fanSpeedValue = speed;
      final speedLabel = ['LOW', 'MEDIUM', 'HIGH'][speed.round()];
      mqttService.publishMessage('fan_speed', speedLabel);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fan speed set to $speedLabel'),
          backgroundColor: Colors.purple,
        ),
      );
    });
  }

  // Show status dialog with customizable messages
  void _showStatusDialog(String title, String content, {bool isError = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: isError ? Colors.red : Colors.green,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mqttService.disconnect(); // Disconnect from MQTT when leaving the screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detect current theme mode
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fan Control',
          style: GoogleFonts.lato(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            _buildSlider(
              "FAN SPEED",
              _fanSpeedValue,
              0,
              2,
              _changeFanSpeed,
              divisions: 2,
              labels: ["LOW", "MEDIUM", "HIGH"],
              textColor: isDarkMode ? Colors.white : Colors.black, // Adjust text color based on theme
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isConnected ? _toggleFan : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFanOn ? Colors.red : Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: Text(
                isFanOn ? 'Turn Fan Off' : 'Turn Fan On',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build slider for fan speed control
  Widget _buildSlider(
      String title,
      double value,
      double min,
      double max,
      ValueChanged<double> onChanged, {
        int? divisions,
        List<String>? labels,
        required Color textColor, // Added text color parameter
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          activeColor: Colors.purple,
          label: labels != null ? labels[value.round()] : null,
        ),
      ],
    );
  }
}
