import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final void Function(bool) onToggleTheme;

  SettingsPage({required this.onToggleTheme});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;

  void _toggleDarkMode(bool value) {
    setState(() {
      isDarkMode = value;
    });
    widget.onToggleTheme(isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('Dark Mode'),
              value: isDarkMode,
              onChanged: _toggleDarkMode,
            ),
            SizedBox(height: 20),
            Text(
              'About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'This is a Smart Home app that allows you to control various aspects of your home, such as lighting, temperature, and more.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
