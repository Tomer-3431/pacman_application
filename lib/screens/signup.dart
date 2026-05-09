import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pacman_application/database/game_user.dart';
import 'package:pacman_application/database/session.dart';
import 'package:pacman_application/screens/login.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/utils/bonus_type.dart';
import 'package:pacman_application/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Signup screen that allows users to create an account using:
///
/// - Email and password.
/// - Google authentication.
///
/// The screen also stores user information locally using
/// [SharedPreferences].
class Signup extends StatefulWidget {
  /// Creates the signup screen.
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

/// State class for the [Signup] screen.
class _SignupState extends State<Signup> {
  /// Indicates whether the user accepted the Terms of Service.
  bool _acceptedTerms = false;

  /// Indicates whether the Google sign-in process is running.
  bool _isGoogleLoading = false;

  /// Message displayed to the user.
  String _message = '';

  /// Controller for the username field.
  final TextEditingController _nameController = TextEditingController();

  /// Controller for the email field.
  final TextEditingController _emailController = TextEditingController();

  /// Controller for the password field.
  final TextEditingController _passwordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  /// Returns whether all required fields are filled.
  bool get _canContinue {
    return _nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _acceptedTerms;
  }

  /// Saves the currently logged-in user locally.
  Future<void> _saveUserPreferences(GameUser user) async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    await preferences.setString('lastUser/uid', user.uid);
    await preferences.setString('lastUser/name', user.name);
    await preferences.setInt('lastUser/highScore', user.highScore);
    await preferences.setString('lastUser/email', user.email);

    for (final MapEntry<BonusType, int> bonusEntry
        in user.bonusTable.entries) {
      await preferences.setInt(
        'lastUser/bonusTable/${bonusEntry.key.name}',
        bonusEntry.value,
      );
    }
  }

  /// Returns whether the Firebase user is new.
  Future<bool> _isNewUser(String userId) async {
    final DatabaseReference userReference =
        FirebaseDatabase.instance.ref('users/$userId');

    return !(await userReference.get()).exists;
  }

  /// Creates the default bonus table.
  Map<String, int> _createDefaultBonusTable() {
    return {
      'apple': 0,
      'bell': 0,
      'cherry': 0,
      'galaxian': 0,
      'key': 0,
      'melon': 0,
      'orange': 0,
      'strawberry': 0,
    };
  }

  /// Creates a database record for a new user.
  Future<void> _createDatabaseUser({
    required String userId,
    required String name,
    required String email,
  }) async {
    final DatabaseReference userReference =
        FirebaseDatabase.instance.ref('users/$userId');

    await userReference.set({
      'name': name,
      'email': email,
      'highScore': anonymousHighScore,
      'bonusTable': _createDefaultBonusTable(),
    });
  }

  /// Updates the global session user.
  Future<void> _setCurrentUser({
    required String userId,
    required String name,
    required String email,
  }) async {
    isAnonymous = false;

    currentUser = GameUser(
      uid: userId,
      name: name,
      highScore: anonymousHighScore,
      email: email,
      bonusTable: anonymousBonusTable,
    );

    await _saveUserPreferences(currentUser);
  }

  /// Navigates to the login screen.
  void _goToLoginScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  /// Signs up the user using Google authentication.
  Future<void> _signUpWithGoogle() async {
    if (!_acceptedTerms) {
      setState(() {
        _message = 'Please accept the TOS before continuing.';
      });

      return;
    }

    setState(() {
      _isGoogleLoading = true;
      _message = '';
    });

    try {
      final GoogleSignInAccount? googleAccount =
          await GoogleSignIn().signIn();

      if (googleAccount == null) {
        setState(() {
          _isGoogleLoading = false;
        });

        return;
      }

      final GoogleSignInAuthentication googleAuthentication =
          await googleAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuthentication.accessToken,
        idToken: googleAuthentication.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User firebaseUser = userCredential.user!;

      final String userName =
          firebaseUser.displayName ?? googleAccount.displayName ?? '';

      final String userEmail =
          firebaseUser.email ?? googleAccount.email;

      if (await _isNewUser(firebaseUser.uid)) {
        await _createDatabaseUser(
          userId: firebaseUser.uid,
          name: userName,
          email: userEmail,
        );
      }

      await _setCurrentUser(
        userId: firebaseUser.uid,
        name: userName,
        email: userEmail,
      );

      if (mounted) {
        _goToLoginScreen();
      }
    } on FirebaseAuthException catch (exception) {
      if (kDebugMode) {
        print('Google sign-up Firebase error: ${exception.code}');
      }

      setState(() {
        _message = exception.code;
      });
    } catch (exception) {
      if (kDebugMode) {
        print('Google sign-up error: $exception');
      }

      setState(() {
        _message = 'something-went-wrong';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  /// Signs up the user using email and password.
  Future<void> _signUpWithEmail() async {
    if (!_acceptedTerms) {
      return;
    }

    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

      await userCredential.user!.updateDisplayName(
        _nameController.text,
      );

      await _createDatabaseUser(
        userId: userCredential.user!.uid,
        name: _nameController.text,
        email: _emailController.text,
      );

      await _setCurrentUser(
        userId: userCredential.user!.uid,
        name: _nameController.text,
        email: _emailController.text,
      );

      if (mounted) {
        _goToLoginScreen();
      }
    } on FirebaseAuthException catch (exception) {
      if (kDebugMode) {
        print(exception.code);
      }

      setState(() {
        _message = exception.code;
      });
    } on FirebaseException catch (exception) {
      if (kDebugMode) {
        print(exception.code);
      }

      setState(() {
        _message = exception.code;
      });
    } catch (exception) {
      if (kDebugMode) {
        print(exception);
      }
    }
  }

  /// Builds a text input section.
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Theme.of(context).primaryColor),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onSubmitted: (_) => setState(() {}),
        ),
      ],
    );
  }

  /// Builds the Google sign-up button.
  Widget _buildGoogleButton() {
    return OutlinedButton(
      onPressed: _isGoogleLoading ? null : _signUpWithGoogle,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(1000, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: Colors.grey.shade300),
        backgroundColor: Colors.white,
      ),
      child: _isGoogleLoading
          ? SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).primaryColor,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/GoogleG.png'),
                const SizedBox(width: 10),
                const Text(
                  'Continue with Google',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbar(
        context: context,
        header: Text('SIGN UP', style: headerTextStyle),
        canLogout: false,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 50,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                Text(
                  'Enter these fields to make an account on the app',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  label: 'Name',
                  controller: _nameController,
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                _buildInputField(
                  label: 'Password',
                  controller: _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _acceptedTerms = value ?? false;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        'I agree to the TOS and Privacy Policy',
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _canContinue ? _signUpWithEmail : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(1000, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: _canContinue
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).focusColor,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey.shade300),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey.shade300),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildGoogleButton(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Have an Account?  ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: _goToLoginScreen,
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        _message.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'PressStart',
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}