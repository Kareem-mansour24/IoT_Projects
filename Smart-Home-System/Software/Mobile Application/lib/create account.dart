
import 'package:flutter/material.dart';


class CreateAccountPage extends StatefulWidget {
  @override
  _CreateAccountPageState createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  List<Map<String, String>> accounts = [];

  void _createAccount() {
    String email = emailController.text;
    String password = passwordController.text;

    bool emailExists = accounts.any((account) => account['email'] == email);

    if (emailExists) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This email already exists')),
      );
    } else {
      // Add new account
      setState(() {
        accounts.add({'email': email, 'password': password});
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
