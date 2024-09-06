// DashboardScreen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Door.dart';
import 'mqtt_service_v2.dart'; // Use MQTTServiceV2 if that's the intended type
import 'setting_page.dart';
import 'Edit Profile Page.dart';
import 'light.dart';
import 'temperature.dart';
import 'pool.dart'; // Updated import for the Pool Control
import 'alarm_system.dart'; // New import for the Alarm System
import 'solar_panel.dart'; // New import for the Solar Panel

class DashboardScreen extends StatelessWidget {
  final List<Map<String, String>> accounts;
  final void Function(bool) onToggleTheme;
  MQTTServiceV2 mqttService = MQTTServiceV2(); // Use the correct type

  DashboardScreen({required this.accounts, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Hello!',
          style: GoogleFonts.lato(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // Fan Control Widget
                  _buildRoomCard('Fan', Icons.ac_unit, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TemperatureControlPage()),
                    );
                  }),
                  // Light Control Widget
                  _buildRoomCard('Light', Icons.lightbulb, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LightPage()),
                    );
                  }),
                  // Door Control Widget
                  _buildRoomCard('Door', Icons.door_back_door_outlined, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoorControlPage(mqttService: mqttService),
                      ),
                    );
                  }),
                  // Alarm System Widget
                  _buildRoomCard('Alarm System', Icons.security, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AlarmSystemPage()),
                    );
                  }),
                  // Pool Control Widget
                  _buildRoomCard('Pool', Icons.pool, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PoolControlPage()),
                    );
                  }),
                  // Solar Panel Widget
                  _buildRoomCard('Solar Panel', Icons.solar_power, onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SolarPanelPage()),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 10),
            _buildBottomNavigationBar(context),
          ],
        ),
      ),
    );
  }

  // Helper method to build each room card widget
  Widget _buildRoomCard(String title, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.purple),
            SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.lato(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom navigation bar setup
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 10,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      onTap: (index) {
        if (index == 1) {
          // Person icon
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(
                account: accounts[0], // Assuming the first account is logged in
                onSave: (updatedAccount) {
                  accounts[0] = updatedAccount;
                },
              ),
            ),
          );
        } else if (index == 2) {
          // Settings icon
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsPage(
                onToggleTheme: onToggleTheme,
              ),
            ),
          );
        }
      },
    );
  }
}
