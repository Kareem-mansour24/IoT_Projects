// change_door_password.dart
import 'package:flutter/material.dart';
import 'base_mqtt_service.dart';

class ChangePasswordPage extends StatefulWidget {
  final String currentPassword;
  final void Function(String) onChangePassword;
  final BaseMQTTService mqttService;

  ChangePasswordPage({
    required this.currentPassword,
    required this.onChangePassword,
    required this.mqttService, // Use the provided MQTT service instance
  });

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Subscribe to the topic to listen for new password updates
    widget.mqttService.subscribeToTopic('change_password', _onPasswordUpdateReceived);
  }

  void _onPasswordUpdateReceived(String topic, String message) {
    if (topic == 'change_password') {
      // Update the password when a new password is received from the topic
      widget.onChangePassword(message);
      _showSuccessNotification();
      Navigator.of(context).pop(); // Go back to the previous screen
    }
  }

  void _changePassword() {
    if (_currentPasswordController.text != widget.currentPassword) {
      _showErrorDialog('Current password is incorrect.');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorDialog('New passwords do not match.');
      return;
    }

    // Publish the new password to the MQTT topic
    widget.mqttService.publishMessage(
      'change_password',
      _newPasswordController.text, // Send the new password instead of a success message
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password has been changed successfully.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Do not disconnect when navigating back
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPasswordField(_currentPasswordController, 'Current Password'),
            SizedBox(height: 20),
            _buildPasswordField(_newPasswordController, 'New Password'),
            SizedBox(height: 20),
            _buildPasswordField(_confirmPasswordController, 'Confirm New Password'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _changePassword,
              child: Text('Change Password'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  @override
  void dispose() {
    // Do not disconnect from MQTT to maintain the shared connection
    super.dispose();
  }
}