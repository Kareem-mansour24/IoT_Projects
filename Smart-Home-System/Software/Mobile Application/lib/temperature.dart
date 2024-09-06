import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mqtt_service_v2.dart'; // Use the correct MQTT service implementation

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TemperatureControlPage(),
    );
  }
}

class TemperatureControlPage extends StatefulWidget {
  @override
  _TemperatureControlPageState createState() => _TemperatureControlPageState();
}

class _TemperatureControlPageState extends State<TemperatureControlPage> {
  final MQTTServiceV2 mqttService = MQTTServiceV2(); // Updated to MQTTServiceV2
  double _fanSpeedValue = 1;
  bool isFanOn = false;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToMQTT(); // Connect to MQTT broker on initialization
  }

  // Connect to MQTT broker using MQTTServiceV2
  Future<void> _connectToMQTT() async {
    isConnected = await mqttService.connect(
      username: 'faresmohamed260',
      password: '#Rmc136a1drd47r',
    );
    setState(() {
      if (isConnected) {
        print('Successfully connected to MQTT broker');
      } else {
        print('Failed to connect to MQTT broker');
      }
    });

    // Subscribe to relevant topics
    if (isConnected) {
      mqttService.subscribeToTopic('fan_power', _onMessageReceived);
      mqttService.subscribeToTopic('fan_speed', _onMessageReceived);
    }
  }

  // Handle incoming messages from MQTT
  void _onMessageReceived(String topic, String message) {
    print('Received message: $message from topic: $topic');
    // You can handle specific topic messages here if needed
  }

  // Toggle fan on/off and publish 'LOW' to MQTT
  void _toggleFan() {
    setState(() {
      isFanOn = !isFanOn;
      mqttService.publishMessage('fan_power', 'LOW'); // Publish ON/OFF based on state
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

  @override
  void dispose() {
    mqttService.disconnect(); // Disconnect from MQTT when leaving the screen
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fan Control',
          style: GoogleFonts.lato(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Icon(Icons.more_vert, color: Colors.black),
        ],
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

  Widget _buildSlider(
      String title,
      double value,
      double min,
      double max,
      ValueChanged<double> onChanged, {
        int? divisions,
        List<String>? labels,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
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