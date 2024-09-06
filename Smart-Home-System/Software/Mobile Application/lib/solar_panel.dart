import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SolarPanelPage extends StatefulWidget {
  @override
  _SolarPanelPageState createState() => _SolarPanelPageState();
}

class _SolarPanelPageState extends State<SolarPanelPage> {
  double batteryLevel = 75.0; // Example battery level in percentage
  bool isSystemActive = true; // State of the solar system

  // Toggle the solar panel system on or off
  void _toggleSystem() {
    setState(() {
      isSystemActive = !isSystemActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Solar Panel Control',
          style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSystemActive ? Icons.battery_full : Icons.battery_alert,
              size: 100,
              color: isSystemActive ? Colors.green : Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              'Battery Level: ${batteryLevel.toStringAsFixed(1)}%',
              style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleSystem,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSystemActive ? Colors.red : Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: GoogleFonts.lato(fontSize: 18),
              ),
              child: Text(isSystemActive ? 'Deactivate System' : 'Activate System'),
            ),
          ],
        ),
      ),
    );
  }
}
