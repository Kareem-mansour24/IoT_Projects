// door_control_page.dart
import 'package:flutter/material.dart';
import 'change_door_password.dart'; // Ensure this file is correctly implemented and imported
import 'mqtt_service_v2.dart'; // Ensure MQTTService is correctly implemented and imported

class DoorControlPage extends StatefulWidget {
  final MQTTServiceV2 mqttService;

  DoorControlPage({required this.mqttService});

  @override
  _DoorControlPageState createState() => _DoorControlPageState();
}

class _DoorControlPageState extends State<DoorControlPage> {
  String enteredPassword = '';
  String correctPassword = '1234'; // Example correct password
  String doorStatus = 'Locked'; // Initial door status
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToMQTT(); // Connect to MQTT on initialization
  }

  @override
  void dispose() {
    widget.mqttService.disconnect(); // Disconnect MQTT when disposing
    super.dispose();
  }

  // Connect to the MQTT broker
  void _connectToMQTT() async {
    isConnected = await widget.mqttService.connect(
      username: 'faresmohamed260',
      password: '#Rmc136a1drd47r',
    );

    setState(() {
      if (isConnected) {
        // Subscribe to the front door topic to receive the lock status
        widget.mqttService.subscribeToTopic('front_door', (topic, message) {
          if (topic == 'front_door') {
            setState(() {
              // Update the door status based on the received message
              doorStatus = message == 'UNLOCKED' ? 'Unlocked' : 'Locked';
            });
          }
        });
      } else {
        _showStatusDialog(
          'MQTT Connection Failed',
          'Could not connect to the MQTT broker.',
          isError: true,
        );
      }
    });
  }

  void _onNumberPressed(String number) {
    setState(() {
      enteredPassword += number;
    });
  }

  void _onClearPressed() {
    setState(() {
      enteredPassword = '';
    });
  }

  void _onSubmitPressed() {
    if (enteredPassword == correctPassword) {
      _openDoor();
    }
    setState(() {
      enteredPassword = '';
    });
  }

  // Publish a message to unlock the door
  void _openDoor() {
    widget.mqttService.publishMessage('unlock_button', 'LOW');
  }

  // Show a dialog with the given title and content
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Door Control'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPasswordInputSection(),
            SizedBox(height: 20),
            _buildNumberPad(),
            SizedBox(height: 20),
            _buildChangePasswordButton(),
            SizedBox(height: 20),
            _buildDoorStatus(),
          ],
        ),
      ),
    );
  }

  // Build the password input section with masked input display
  Widget _buildPasswordInputSection() {
    return Column(
      children: [
        Text(
          'Enter Password',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade200,
          ),
          child: Text(
            enteredPassword.isEmpty ? '****' : '*' * enteredPassword.length,
            style: TextStyle(fontSize: 32, letterSpacing: 4),
          ),
        ),
      ],
    );
  }

  // Build the numeric pad for entering the password
  Widget _buildNumberPad() {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      physics: NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: List.generate(9, (index) {
        return ElevatedButton(
          onPressed: () => _onNumberPressed('${index + 1}'),
          child: Text('${index + 1}', style: TextStyle(fontSize: 24)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(20),
          ),
        );
      })
        ..add(_buildClearButton())
        ..add(_buildZeroButton())
        ..add(_buildSubmitButton()),
    );
  }

  // Clear button on the numeric pad
  Widget _buildClearButton() {
    return ElevatedButton(
      onPressed: _onClearPressed,
      child: Text('Clear', style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(20),
      ),
    );
  }

  // Zero button on the numeric pad
  Widget _buildZeroButton() {
    return ElevatedButton(
      onPressed: () => _onNumberPressed('0'),
      child: Text('0', style: TextStyle(fontSize: 24)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(20),
      ),
    );
  }

  // Submit button to validate the password
  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _onSubmitPressed,
      child: Text('Submit', style: TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(20),
      ),
    );
  }

  // Button to navigate to the Change Password page
  Widget _buildChangePasswordButton() {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangePasswordPage(
              currentPassword: correctPassword,
              onChangePassword: (newPassword) {
                correctPassword = newPassword;
                _showStatusDialog('Password Updated', 'The password has been updated successfully.');
              },
              mqttService: widget.mqttService, // Pass the MQTTService instance here
            ),
          ),
        );
      },
      icon: Icon(Icons.lock_reset, color: Colors.white),
      label: Text(
        'Change Password',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }


  // Display the door status with an icon and color indicator
  Widget _buildDoorStatus() {
    return _buildStatusCard(
      title: 'Door Status',
      status: doorStatus,
      icon: doorStatus == 'Unlocked' ? Icons.lock_open : Icons.lock,
      color: doorStatus == 'Unlocked' ? Colors.green : Colors.red,
    );
  }

  // Helper method to build status cards
  Widget _buildStatusCard({
    required String title,
    required String status,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: ListTile(
        leading: Icon(icon, color: color, size: 40),
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Text(
              'Status: $status',
              style: TextStyle(fontSize: 16, color: color),
            ),
            SizedBox(width: 10),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: status == 'Unlocked' ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}