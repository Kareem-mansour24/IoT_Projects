import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mqtt_service.dart'; // Import your MQTT service

class LightPage extends StatefulWidget {
  @override
  _LightPageState createState() => _LightPageState();
}

class _LightPageState extends State<LightPage> {
  final MQTTService mqttService = MQTTService();
  bool isFrontDoorLightOn = false;
  bool isRoomLightOn = false;
  bool areAllLightsOn = false;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToMQTT(); // Connect to MQTT broker on initialization
  }

  // Connect to MQTT broker using MQTTService
  Future<void> _connectToMQTT() async {
    isConnected = await mqttService.connect(
        username: 'faresmohamed260',
        password: '#Rmc136a1drd47r'
    );
    setState(() {
      if (isConnected) {
        print('Successfully connected to MQTT broker');
      } else {
        print('Failed to connect to MQTT broker');
      }
    });
  }

  // Toggle the front door light and publish the state to MQTT
  void _toggleFrontDoorLight() {
    setState(() {
      isFrontDoorLightOn = !isFrontDoorLightOn;
      mqttService.publishMessage(
        'light/frontdoor',
        isFrontDoorLightOn ? 'FRONT_DOOR_LIGHT_ON' : 'FRONT_DOOR_LIGHT_OFF',
      );
      _updateAllLightsState(); // Update the state of the master control
    });
  }

  // Toggle the room light and publish the state to MQTT
  void _toggleRoomLight() {
    setState(() {
      isRoomLightOn = !isRoomLightOn;
      mqttService.publishMessage(
        'light/room',
        isRoomLightOn ? 'ROOM_LIGHT_ON' : 'ROOM_LIGHT_OFF',
      );
      _updateAllLightsState(); // Update the state of the master control
    });
  }

  // Toggles all lights based on the master switch state
  void _toggleAllLights() {
    setState(() {
      areAllLightsOn = !areAllLightsOn;
      isFrontDoorLightOn = areAllLightsOn;
      isRoomLightOn = areAllLightsOn;
      mqttService.publishMessage(
        'light/all',
        areAllLightsOn ? 'ALL_LIGHTS_ON' : 'ALL_LIGHTS_OFF',
      );
    });
  }

  // Function to update the state of the master control based on individual light states
  void _updateAllLightsState() {
    setState(() {
      areAllLightsOn = isFrontDoorLightOn && isRoomLightOn;
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
          'Light Control',
          style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Front Door Light Control
            _buildLightControl(
              title: 'Front Door Light',
              isLightOn: isFrontDoorLightOn,
              onToggle: isConnected ? _toggleFrontDoorLight : null,
            ),
            SizedBox(height: 20),
            // Room Light Control
            _buildLightControl(
              title: 'Room Light',
              isLightOn: isRoomLightOn,
              onToggle: isConnected ? _toggleRoomLight : null,
            ),
            SizedBox(height: 20),
            // Master Control for All Lights
            _buildLightControl(
              title: 'All Lights',
              isLightOn: areAllLightsOn,
              onToggle: isConnected ? _toggleAllLights : null,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a light control button with its icon
  Widget _buildLightControl({
    required String title,
    required bool isLightOn,
    required VoidCallback? onToggle,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: ListTile(
        leading: Icon(
          isLightOn ? Icons.lightbulb : Icons.lightbulb_outline,
          color: isLightOn ? Colors.yellow : Colors.grey,
          size: 40,
        ),
        title: Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: isLightOn ? Colors.black : Colors.black54,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: onToggle,
          style: ElevatedButton.styleFrom(
            backgroundColor: isLightOn ? Colors.red : Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Text(
            isLightOn ? 'Turn Off' : 'Turn On',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
