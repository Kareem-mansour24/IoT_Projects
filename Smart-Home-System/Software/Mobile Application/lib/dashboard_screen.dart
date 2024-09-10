import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/fan.dart';
import 'door.dart';
import 'pool.dart';
import 'setting_page.dart';
import 'solar_panel.dart';
import 'edit_profile_page.dart';
import 'light.dart';
import 'mqtt_service_v2.dart';
import 'alarm_system.dart';

class DashboardScreen extends StatefulWidget {
  final List<Map<String, String>> accounts;
  final void Function(bool) onToggleTheme;

  DashboardScreen({required this.accounts, required this.onToggleTheme});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = true;
  String _userName = 'User';
  bool isDarkMode = false; // Track the current dark mode state
  final MQTTServiceV2 mqttService = MQTTServiceV2();

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _loadThemePreference(); // Load the theme preference on initialization
  }

  @override
  void dispose() {
    mqttService.disconnect(); // Clean up MQTT connection
    super.dispose();
  }

  Future<void> _fetchUser() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        setState(() {
          _user = user;
          _userName = user.displayName ?? 'User'; // Fetch user display name
        });
      }
    } catch (e) {
      print('Error fetching user: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Load the current theme preference
  Future<void> _loadThemePreference() async {
    // Add code here to load theme preference, for example using SharedPreferences
    // Assume isDarkMode is set from SharedPreferences or other state management solution
    // Example:
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   isDarkMode = prefs.getBool('isDarkMode') ?? false;
    // });
  }

  // Function to refresh the username after editing the profile
  void _refreshUserData() async {
    await _auth.currentUser?.reload();
    User? updatedUser = _auth.currentUser;
    setState(() {
      _user = updatedUser;
      _userName = updatedUser?.displayName ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Welcome, $_userName!',
                  style: GoogleFonts.lato(
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis, // Handles long usernames gracefully
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildRoomCard(
                    'Fan',
                    Icons.ac_unit,
                    onTap: () {
                      _navigateTo(context, FanControlPage());
                    },
                  ),
                  _buildRoomCard(
                    'Light',
                    Icons.lightbulb,
                    onTap: () {
                      _navigateTo(context, LightPage());
                    },
                  ),
                  _buildRoomCard(
                    'Door',
                    Icons.door_back_door_outlined,
                    onTap: () {
                      _navigateTo(context, DoorControlPage(mqttService: mqttService));
                    },
                  ),
                  _buildRoomCard(
                    'Alarm System',
                    Icons.security,
                    onTap: () {
                      _navigateTo(context, AlarmSystemPage());
                    },
                  ),
                  _buildRoomCard(
                    'Pool',
                    Icons.pool,
                    onTap: () {
                      _navigateTo(context, PoolControlPage());
                    },
                  ),
                  _buildRoomCard(
                    'Solar Panel',
                    Icons.solar_power,
                    onTap: () {
                      _navigateTo(context, SolarPanelPage());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildBottomNavigationBar(context),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    } catch (e) {
      print('Error navigating: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation Error: $e')),
      );
    }
  }

  Widget _buildRoomCard(String title, IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.purple),
            const SizedBox(height: 10),
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

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      elevation: 10,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
      onTap: (index) {
        if (index == 1) {
          _navigateToProfile();
        } else if (index == 2) {
          _navigateToSettings();
        }
      },
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          account: widget.accounts.isNotEmpty ? widget.accounts[0] : {},
          onSave: (updatedAccount) {
            if (widget.accounts.isNotEmpty) {
              widget.accounts[0] = updatedAccount;
            }
            _refreshUserData(); // Refresh the user data to update the welcome message
          },
        ),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          isDarkMode: isDarkMode, // Pass the dark mode state correctly
          onToggleTheme: (value) {
            setState(() {
              isDarkMode = value;
              widget.onToggleTheme(value); // Update the main app's theme
            });
          },
        ),
      ),
    );
  }
}
