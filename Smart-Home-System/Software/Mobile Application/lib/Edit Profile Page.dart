import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, String> account;
  final void Function(Map<String, String>) onSave;

  EditProfilePage({required this.account, required this.onSave});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.account['email']);
    passwordController = TextEditingController(text: widget.account['password']);
  }

  void _saveChanges() {
    String updatedEmail = emailController.text;
    String updatedPassword = passwordController.text;

    widget.onSave({
      'email': updatedEmail,
      'password': updatedPassword,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
