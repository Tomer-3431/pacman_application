import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacman_application/constants.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/screens/login.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<StatefulWidget> createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();

  // Tracks whether the reset email was sent successfully.
  bool _emailSent = false;

  // Holds an error message to display beneath the text field.
  String? _errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void _sendResetEmail() async {
    // Clear any previous error before trying again.
    setState(() => _errorMessage = null);

    final email = emailController.text.trim();

    if (email.isEmpty) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() => _emailSent = true);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('error: ${e.code}');

      // Map common Firebase error codes to friendly messages.
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'No account found for this email address.';
            break;
          case 'invalid-email':
            _errorMessage = 'Please enter a valid email address.';
            break;
          case 'too-many-requests':
            _errorMessage = 'Too many attempts. Please try again later.';
            break;
          default:
            _errorMessage = 'Something went wrong. Please try again.';
        }
      });
    } catch (e) {
      if (kDebugMode) print(e);
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: Appbar(
      context: context,
      header: Text(
        "FORGOT PASSWORD",
        style: headerTextStyle
      ),
      canLogout: false,
    ),
    body: SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Column(
          spacing: 10,
          children: [
            const SizedBox(height: 150),
            Text(
              "Enter your email and we'll send you a link to reset your password.",
              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
            ),
            
            const SizedBox(height: 25),
            
            // ── Email field (hidden once email is sent) ───────────
            if (!_emailSent) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Email",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(height: 2),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _sendResetEmail(),
                  ),
            
                  // Error message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            
              const SizedBox(height: 25),
            
              // ── Send reset link button ─────────────────────────
              ElevatedButton(
                onPressed: emailController.text.trim().isEmpty
                    ? null
                    : _sendResetEmail,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(1000, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(8),
                  ),
                  backgroundColor: emailController.text.trim().isEmpty
                      ? Theme.of(context).focusColor
                      : Theme.of(context).primaryColor,
                ),
                child: const Text(
                  "Send Reset Link",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
            
            // ── Success state ─────────────────────────────────────
            if (_emailSent) ...[
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Reset link sent to '${emailController.text}'! \nCheck your inbox.",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            
              const SizedBox(height: 16),
            
              // Allow the user to try a different address.
              GestureDetector(
                onTap: () => setState(() {
                  _emailSent = false;
                  emailController.clear();
                }),
                child: Text(
                  "Try a different email",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // ── Back to Sign In ───────────────────────────────────
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (final BuildContext context) => const Login(),
                  ),
                );
              },
              child: Text(
                "Back to Sign In",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
