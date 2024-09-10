import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_screen.dart';

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn();
  }

  Future<void> _checkIfLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            accounts: [], // You might need to update this if necessary
            onToggleTheme: (bool) {},
          ),
        ),
      );
    }
  }

  bool _validateEmail(String email) {
    final RegExp emailRegExp = RegExp(
      r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+$',
    );
    return emailRegExp.hasMatch(email);
  }

Future<void> _authenticate() async {
  String email = emailController.text.trim();
  String password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    _showError('Please enter both email and password.');
    return;
  }

  if (!_validateEmail(email)) {
    _showError('Please enter a valid email address.');
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    if (_isSignUp) {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account created successfully')),
      );
    } else {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in successfully')),
      );
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          accounts: [], // You might need to update this if necessary
          onToggleTheme: (bool) {},
        ),
      ),
    );
  } on FirebaseAuthException catch (e) {
    // Display "Please try again" for wrong email or password
    String errorMessage = 'Please try again';

    if (_isSignUp && e.code == 'email-already-in-use') {
      errorMessage =
          'The account already exists for that email. Please log in instead.';
      setState(() {
        _isSignUp = false; // Switch to the login form automatically
      });
    } else {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
          errorMessage = 'Please try again';
          break;
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        default:
          errorMessage = 'An error occurred. Please try again.';
      }
    }
    _showError(errorMessage);
  } catch (e) {
    _showError('An unexpected error occurred. Please try again.');
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSignUp ? 'Create Account' : 'Login',
          style: GoogleFonts.lato(),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _authenticate,
                    child: Text(_isSignUp ? 'Create Account' : 'Sign In'),
                  ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSignUp = !_isSignUp;
                });
              },
              child: Text(
                _isSignUp
                    ? 'Already have an account? Sign In'
                    : 'Don\'t have an account? Sign Up',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
