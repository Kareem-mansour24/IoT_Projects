// light.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mqtt_service.dart'; // Ensure you are using the correct MQTT service

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
          'Light Control',
          style: GoogleFonts.lato(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLightControl(
              title: 'Front Door Light',
              isLightOn: isFrontDoorLightOn,
              onToggle: isConnected ? _toggleFrontDoorLight : null,
              textColor: isDarkMode ? Colors.white : Colors.black, // Adjust text color based on theme
            ),
            SizedBox(height: 20),
            _buildLightControl(
              title: 'Room Light',
              isLightOn: isRoomLightOn,
              onToggle: isConnected ? _toggleRoomLight : null,
              textColor: isDarkMode ? Colors.white : Colors.black, // Adjust text color based on theme
            ),
            SizedBox(height: 20),
            _buildLightControl(
              title: 'All Lights',
              isLightOn: areAllLightsOn,
              onToggle: isConnected ? _toggleAllLights : null,
              textColor: isDarkMode ? Colors.white : Colors.black, // Adjust text color based on theme
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
    required Color textColor, // Added text color parameter
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
            color: textColor, // Use the text color based on the theme
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
