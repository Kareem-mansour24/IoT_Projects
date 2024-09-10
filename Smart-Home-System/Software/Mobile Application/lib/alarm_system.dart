// alarm_system.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mqtt_service.dart'; // Ensure you are using the correct MQTT service

class AlarmSystemPage extends StatefulWidget {
  @override
  _AlarmSystemPageState createState() => _AlarmSystemPageState();
}

class _AlarmSystemPageState extends State<AlarmSystemPage> {
  final MQTTService mqttService = MQTTService();
  bool isConnected = false;

  // Sensor states
  bool isFireDetected = false;
  bool isMotionDetected = false;
  double _currentTemperature = 0; // Temperature reading from DHT sensor

  @override
  void initState() {
    super.initState();
    _connectToMQTT(); // Connect to MQTT broker on initialization
  }

  // Connect to MQTT broker using MQTTService with the updated credentials
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
        _subscribeToTopics(); // Subscribe to all relevant topics after successful connection
      }
    });
  }

  // Subscribe to all sensor topics
  void _subscribeToTopics() {
    mqttService.subscribeToTopic('fire_alarm', _onMessageReceived); // Flame and smoke sensor
    mqttService.subscribeToTopic('security_alarm', _onMessageReceived); // Motion detection
    mqttService.subscribeToTopic('dht', _onMessageReceived); // Temperature sensor
  }

  // Handle incoming MQTT messages for all topics
  void _onMessageReceived(String topic, String message) {
    print('Received message: $message from topic: $topic');

    setState(() {
      switch (topic) {
        case 'fire_alarm':
          if (message.trim().toUpperCase() == 'LOW') {
            isFireDetected = true;
            _showAlert(
              'Fire Detected',
              'Fire detected! Evacuate immediately.',
              Colors.red,
            );
          } else if (message.trim().toUpperCase() == 'HIGH') {
            isFireDetected = false; // Reset state when no fire is detected
          }
          break;

        case 'security_alarm':
          if (message.trim().toUpperCase() == 'LOW') {
            isMotionDetected = true;
            _showAlert(
              'Motion Detected',
              'Movement detected in the monitored area.',
              Colors.orange,
            );
          } else if (message.trim().toUpperCase() == 'HIGH') {
            isMotionDetected = false; // Reset state when no motion is detected
          }
          break;

        case 'dht':
          try {
            double temperature = double.parse(message.trim());
            _currentTemperature = temperature;
          } catch (e) {
            print('Error parsing temperature data: $e');
          }
          break;

        default:
          print('Unhandled topic: $topic');
      }
    });
  }

  // Display an alert dialog based on sensor detection
  void _showAlert(String title, String content, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: color),
            SizedBox(width: 10),
            Text(title, style: TextStyle(color: color)),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
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

  // Publish to the "online_reset_button" topic and reset sensor states
  void _publishReset() {
    mqttService.publishMessage('online_reset_button', 'LOW');
    setState(() {
      isFireDetected = false; // Reset fire detection state
      isMotionDetected = false; // Reset motion detection state
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reset command sent successfully, and sensor states have been reset.'),
        duration: Duration(seconds: 2),
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
          'Alarm System Control',
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 2,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircularProgressIndicator(
              value: _currentTemperature / 50, // Adjust max temperature for scaling
              strokeWidth: 10,
              color: Colors.purple,
              backgroundColor: Colors.purple.withOpacity(0.3),
            ),
            Text(
              "${_currentTemperature.toStringAsFixed(1)}°", // Display temperature
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.purple, // Adjust text color
              ),
            ),
            Text(
              "TEMPERATURE",
              style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : Colors.purple), // Adjust text color
            ),
            SizedBox(height: 20),
            _buildSensorCard(
              title: 'Fire Alarm',
              isActive: isFireDetected,
              icon: Icons.local_fire_department,
              activeColor: Colors.red,
              textColor: isDarkMode ? Colors.white : Colors.black, // Adjust text color
            ),
            SizedBox(height: 20),
            _buildSensorCard(
              title: 'Security Alarm',
              isActive: isMotionDetected,
              icon: Icons.motion_photos_on,
              activeColor: Colors.orange,
              textColor: isDarkMode ? Colors.white : Colors.black, // Adjust text color
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _publishReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Send Reset Command',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a sensor card
  Widget _buildSensorCard({
    required String title,
    required bool isActive,
    required IconData icon,
    required Color activeColor,
    required Color textColor, // Added text color parameter
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: ListTile(
        leading: Icon(
          icon,
          size: 40,
          color: isActive ? activeColor : Colors.grey,
        ),
        title: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isActive ? activeColor : textColor, // Use the text color based on the theme
          ),
        ),
        trailing: Icon(
          isActive ? Icons.warning_amber_rounded : Icons.check_circle_outline,
          color: isActive ? activeColor : Colors.green,
        ),
      ),
    );
  }
}
