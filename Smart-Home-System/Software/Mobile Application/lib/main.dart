import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/Dashboard%20Screen.dart';

void main() {
  runApp(SmartHomeApp());
}
class SmartHomeApp extends StatefulWidget {
  @override
  _SmartHomeAppState createState() => _SmartHomeAppState();
}

class _SmartHomeAppState extends State<SmartHomeApp> {
  bool isDarkMode = false;

  void _toggleTheme(bool isDarkModeEnabled) {
    setState(() {
      isDarkMode = isDarkModeEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: HomePage(onToggleTheme: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  final void Function(bool) onToggleTheme;

  HomePage({required this.onToggleTheme});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  List<Map<String, String>> accounts = [
    {'email': 'iot@gmail.com', 'password': '1234'},
  ]; // Example account

  void _signIn() {
    String email = emailController.text;
    String password = passwordController.text;

    bool accountExists = accounts.any((account) =>
        account['email'] == email && account['password'] == password);

    if (accountExists) {
      // Navigate to Dashboard
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            accounts: accounts,
            onToggleTheme: widget.onToggleTheme, // Pass theme toggle function
          ),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid email or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8E2DE2),
              Color(0xFF4A00E0),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top Logo and text
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  Icon(
                    Icons.home_outlined,
                    color: Colors.white,
                    size: 100,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'SMART HOME',
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 100),
            // Email TextField
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.person, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Password TextField
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  hintText: 'Password',
                  hintStyle: TextStyle(color: Colors.white),
                  prefixIcon: Icon(Icons.lock, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Sign In Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.center,
                  child: Text(
                    'SIGN IN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Create an Account Button
            TextButton(
              onPressed: () {
                // Navigate to Create Account Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateAccountPage(accounts: accounts)),
                );
              },
              child: Text(
                'CREATE AN ACCOUNT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateAccountPage extends StatefulWidget {
  final List<Map<String, String>> accounts;

  CreateAccountPage({required this.accounts});

  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _createAccount() {
    String email = emailController.text;
    String password = passwordController.text;

    bool emailExists = widget.accounts.any((account) => account['email'] == email);

    if (emailExists) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This email already exists')),
      );
    } else {
      // Add new account
      setState(() {
        widget.accounts.add({'email': email, 'password': password});
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account created successfully')),
      );
      // Navigate back to HomePage
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email TextField
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Password TextField
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Create Account Button
            ElevatedButton(
              onPressed: _createAccount,
              child: Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
