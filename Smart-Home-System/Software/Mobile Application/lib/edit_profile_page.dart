// edit_profile_page.dart
import 'package:firebase_auth/firebase_auth.dart';
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
  late TextEditingController usernameController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.account['email']);
    passwordController = TextEditingController(text: widget.account['password']);
    usernameController = TextEditingController(text: _auth.currentUser?.displayName ?? ''); // Initialize with current username
  }

  Future<void> _saveChanges() async {
    String updatedEmail = emailController.text;
    String updatedPassword = passwordController.text;
    String updatedUsername = usernameController.text;

    if (updatedEmail.isEmpty || updatedPassword.isEmpty || updatedUsername.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter email, password, and username.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        if (updatedEmail != widget.account['email']) {
          await user.updateEmail(updatedEmail);
        }
        if (updatedPassword != widget.account['password']) {
          await user.updatePassword(updatedPassword);
        }
        if (updatedUsername != user.displayName) {
          await user.updateDisplayName(updatedUsername);
        }

        // After updating, refresh the user's data
        await user.reload();
        user = _auth.currentUser;

        // Call onSave callback
        widget.onSave({
          'email': updatedEmail,
          'password': updatedPassword,
          'username': updatedUsername, // Add username to account map
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'requires-recent-login':
          errorMessage = 'Please log in again to update your email, password, or username.';
          break;
        case 'email-already-in-use':
          errorMessage = 'The email address is already in use by another account.';
          break;
        case 'weak-password':
          errorMessage = 'The password is too weak.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 20),
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
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _isLoading ? null : _saveChanges, // Disable button when loading
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
