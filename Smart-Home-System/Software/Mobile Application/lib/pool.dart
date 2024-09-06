import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PoolControlPage extends StatefulWidget {
  @override
  _PoolControlPageState createState() => _PoolControlPageState();
}

class _PoolControlPageState extends State<PoolControlPage> {
  bool isPumpOn = false; // Track the state of the water pump
  bool isWaterLevelSafe = true; // Track the state of the water level sensor

  // Function to toggle the water pump
  void _togglePump() {
    setState(() {
      // Toggle pump only if the water level is safe
      if (isWaterLevelSafe) {
        isPumpOn = !isPumpOn;
      }
    });
  }

  // Simulate water level reaching the safe threshold
  void _checkWaterLevel() {
    if (isPumpOn) {
      // Simulate the sensor detecting unsafe water level after turning the pump on
      setState(() {
        isWaterLevelSafe = false;
        isPumpOn = false; // Automatically stop the pump when water level is unsafe
      });

      // Show a warning message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Water level reached the limit. Pump stopped automatically.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Smart Pool Control',
          style: GoogleFonts.lato(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
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
            // Display the water pump icon and its status
            Icon(
              isPumpOn ? Icons.water_damage : Icons.water,
              size: 100,
              color: isPumpOn ? Colors.blue : Colors.grey,
            ),
            SizedBox(height: 20),
            // Control button for the water pump
            ElevatedButton(
              onPressed: () {
                _togglePump();
                _checkWaterLevel(); // Check water level when toggling the pump
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPumpOn ? Colors.red : Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: GoogleFonts.lato(fontSize: 18),
              ),
              child: Text(isPumpOn ? 'Stop Water Pump' : 'Start Water Pump'),
            ),
            SizedBox(height: 20),
            // Display the water level status
            _buildWaterLevelIndicator(),
          ],
        ),
      ),
    );
  }

  // Widget to display the water level status
  Widget _buildWaterLevelIndicator() {
    return Column(
      children: [
        Icon(
          isWaterLevelSafe ? Icons.water_drop : Icons.warning,
          size: 50,
          color: isWaterLevelSafe ? Colors.blue : Colors.red,
        ),
        SizedBox(height: 10),
        Text(
          isWaterLevelSafe ? 'Water Level: Safe' : 'Water Level: Too High',
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isWaterLevelSafe ? Colors.blue : Colors.red,
          ),
        ),
      ],
    );
  }
}
