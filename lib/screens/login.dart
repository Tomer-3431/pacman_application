import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pacman_application/utils/constants.dart';
import 'package:pacman_application/database/game_user.dart';
import 'package:pacman_application/database/session.dart';
import 'package:pacman_application/utils/bonus_type.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/utils/loading_screen.dart';
import 'package:pacman_application/screens/signup.dart';
import 'package:pacman_application/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The sign-in screen shown on first launch and after sign-out.
///
/// Supports three authentication paths:
/// 1. **Email + password** – via [FirebaseAuth.signInWithEmailAndPassword].
/// 2. **Google Sign-In** – via the `google_sign_in` package.
/// 3. **Guest / anonymous** – skips authentication entirely; score and
///    collectables are not persisted.
///
/// On a successful sign-in the screen saves the user's details to
/// [SharedPreferences] (enabling fast re-launch) and navigates to
/// [LoadingScreen] → [HomeScreen].
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  // ── Fields ───────────────────────────────────────────────────────────────

  /// Controller for the email input field.
  final TextEditingController _emailController = TextEditingController();

  /// Controller for the password input field.
  final TextEditingController _passwordController = TextEditingController();

  /// Whether the Google Sign-In flow is currently in progress.
  bool _googleLoading = false;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Uncomment to re-enable automatic sign-in from cached credentials:
    // _checkPrefs();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      // Already initialised (e.g. hot-reload) – go straight to loading.
      if (currentUser.haveInitialized()) {
        return const LoadingScreen();
      }

      // Firebase reports a signed-in user; reuse their session.
      if (snapshot.hasData) {
        final user = snapshot.data!;
        isAnonymous = false;
        currentUser = GameUser.fromUid(uid: user.uid);
        _savePrefs(currentUser);
        return const LoadingScreen();
      }

      return Scaffold(
        appBar: Appbar(
          context: context,
          header: Text('LOGIN', style: headerTextStyle),
          canLogout: false,
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 150),
                  Column(
                    spacing: 10,
                    children: [
                      Text(
                        'Hi there! Nice to see you again.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                      ),

                      const SizedBox(height: 15),

                      // ── Email field ────────────────────────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextField(
                            controller: _emailController,
                            onSubmitted: (_) => setState(() {}),
                          ),
                        ],
                      ),

                      // ── Password field ─────────────────────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Password',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            onSubmitted: (_) => setState(() {}),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // ── Sign In button ─────────────────────────────────
                      ElevatedButton(
                        onPressed: () async {
                          if (_emailController.text.isNotEmpty &&
                              _passwordController.text.isNotEmpty) {
                            try {
                              final credentials = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );

                              isAnonymous = false;
                              currentUser = GameUser.fromUid(
                                uid: credentials.user!.uid,
                              );
                              _savePrefs(currentUser);

                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomeScreen(),
                                  ),
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              if (kDebugMode) print('error: ${e.code}');
                            } catch (e) {
                              if (kDebugMode) print(e);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(1000, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                          backgroundColor:
                              _emailController.text.isEmpty ||
                                  _passwordController.text.isEmpty
                              ? Theme.of(context).focusColor
                              : Theme.of(context).primaryColor,
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      // ── Divider ────────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: Colors.grey.shade300),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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

                      // ── Google Sign-In button ──────────────────────────
                      OutlinedButton(
                        onPressed:
                            _googleLoading ? null : _signInWithGoogle,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(1000, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                          side: BorderSide(color: Colors.grey.shade300),
                          backgroundColor: Colors.white,
                        ),
                        child: _googleLoading
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
                      ),

                      const SizedBox(height: 10),

                      // ── Sign Up link ───────────────────────────────────
                      GestureDetector(
                        onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const Signup()),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── Guest entry ────────────────────────────────────
                      GestureDetector(
                        onTap: () {
                          isAnonymous = true;
                          _removePrefs();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HomeScreen(),
                            ),
                          );
                        },
                        child: const Text('Enter as a guest'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  // ── Private methods ──────────────────────────────────────────────────────

  /// Checks [SharedPreferences] for a previously saved user session and
  /// signs in automatically if one exists, bypassing the login form.
  ///
  /// Currently unused – uncomment the call in [initState] to enable.
  // ignore: unused_element
  void _checkPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final lastUserId = prefs.getString('lastUser/uid');
    final lastUserName = prefs.getString('lastUser/name');
    final lastUserHighScore = prefs.getInt('lastUser/highScore');
    final lastUserEmail = prefs.getString('lastUser/email');

    final entries = await Future.wait(
      BonusType.values.map((bonus) => _bonusEntryFromPrefs(bonus, prefs)),
    );

    if (lastUserId != null && mounted) {
      isAnonymous = false;
      currentUser = GameUser(
        uid: lastUserId,
        name: lastUserName ?? currentUser.name,
        highScore: lastUserHighScore ?? currentUser.highScore,
        email: lastUserEmail ?? currentUser.email,
        bonusTable: <BonusType, int>{}..addEntries(entries),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoadingScreen()),
      );
    }
  }

  /// Reads the stored count for [bonus] from [prefs] and returns it as a
  /// [MapEntry] for reconstructing the bonus table.
  Future<MapEntry<BonusType, int>> _bonusEntryFromPrefs(
    BonusType bonus,
    SharedPreferences prefs,
  ) async {
    return MapEntry(
      bonus,
      prefs.getInt('lastUser/bonusTable/${bonus.name}') ?? 0,
    );
  }

  /// Persists all relevant fields of [user] to [SharedPreferences] so the
  /// player can be automatically signed in on the next launch.
  void _savePrefs(GameUser user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('lastUser/uid', user.uid);
    await prefs.setString('lastUser/name', user.name);
    await prefs.setInt('lastUser/highScore', user.highScore);
    await prefs.setString('lastUser/email', user.email);

    for (final entry in user.bonusTable.entries) {
      await prefs.setInt(
        'lastUser/bonusTable/${entry.key.name}',
        entry.value,
      );
    }
  }

  /// Removes all "lastUser/*" keys from [SharedPreferences], preventing
  /// automatic sign-in on the next launch (used when the player signs out).
  void _removePrefs() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('lastUser/uid');
    await prefs.remove('lastUser/name');
    await prefs.remove('lastUser/highScore');
    await prefs.remove('lastUser/email');

    for (final bonus in BonusType.values) {
      await prefs.remove('lastUser/bonusTable/${bonus.name}');
    }
  }

  /// Initiates the Google Sign-In flow and signs the resulting credential
  /// into Firebase Auth.
  ///
  /// On success, sets [currentUser] and navigates to [LoadingScreen].
  void _signInWithGoogle() async {
    setState(() => _googleLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // User cancelled the account picker.
      if (googleUser == null) {
        setState(() => _googleLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      isAnonymous = false;
      currentUser = GameUser.fromUid(uid: userCredential.user!.uid);
      _savePrefs(currentUser);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoadingScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Google sign-in Firebase error: ${e.code}');
    } catch (e) {
      if (kDebugMode) print('Google sign-in error: $e');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }
}