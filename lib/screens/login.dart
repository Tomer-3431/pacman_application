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

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _googleLoading = false;

  @override
  void initState() {
    super.initState();

    // _checkPrefs();
  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  void _checkPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final lastUserId = prefs.getString("lastUser/uid");
    final lastUserName = prefs.getString("lastUser/name");
    final lastUserHighScore = prefs.getInt("lastUser/highScore");
    final lastUserEmail = prefs.getString("lastUser/email");

    final entries = await Future.wait(
      BonusType.values.map((bonus) => _bonusTablePrefs(bonus, prefs)),
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
        MaterialPageRoute(builder: (context) => LoadingScreen()),
      );
    }
  }

  Future<MapEntry<BonusType, int>> _bonusTablePrefs(
    BonusType bonus,
    SharedPreferences prefs,
  ) async {
    return MapEntry(
      bonus,
      prefs.getInt("lastUser/bonusTable/${bonus.name}") ?? 0,
    );
  }

  void _savePrefs(GameUser user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("lastUser/uid", user.uid);
    await prefs.setString("lastUser/name", user.name);
    await prefs.setInt("lastUser/highScore", user.highScore);
    await prefs.setString("lastUser/email", user.email);
    for (MapEntry<BonusType, int> entries in user.bonusTable.entries) {
      await prefs.setInt(
        "lastUser/bonusTable/${entries.key.name}",
        entries.value,
      );
    }
  }

  void _removePrefs() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("lastUser/uid");
    await prefs.remove("lastUser/name");
    await prefs.remove("lastUser/highScore");
    await prefs.remove("lastUser/email");
    for (BonusType bonus in BonusType.values) {
      await prefs.remove("lastUser/bonusTable/${bonus.name}");
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────
  void _signInWithGoogle() async {
    setState(() => _googleLoading = true);

    try {
      // Opens the Google account picker.
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // User cancelled the picker.
      if (googleUser == null) {
        setState(() => _googleLoading = false);
        return;
      }

      // Exchange the Google token for a Firebase credential.
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      isAnonymous = false;
      currentUser = GameUser.fromUid(uid: userCredential.user!.uid);
      _savePrefs(currentUser);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (final BuildContext context) => LoadingScreen(),
          ),
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (currentUser.haveInitalized()) {
        return LoadingScreen();
      }

      if (snapshot.hasData) {
        final user = snapshot.data!;
        isAnonymous = false;
        currentUser = GameUser.fromUid(uid: user.uid);
        _savePrefs(currentUser);
        return LoadingScreen();
      }

      return Scaffold(
        appBar: Appbar(
          context: context,
          header: Text("LOGIN", style: headerTextStyle),
          canLogout: false,
        ),
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 150),
                  Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Text(
                        "Hi there! Nice to see you again.",
                        style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                      ),

                      SizedBox(height: 15),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 2,
                        children: [
                          Text(
                            "Email",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextField(
                            controller: emailController,
                            // keyboardType: TextInputType.emailAddress,
                            onSubmitted: (text) => setState(() {}),
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Password",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            onSubmitted: (value) => setState(() {}),
                          ),
                        ],
                      ),

                      SizedBox(height: 15),

                      ElevatedButton(
                        onPressed: () async {
                          if (emailController.text.isNotEmpty &&
                              passwordController.text.isNotEmpty) {
                            try {
                              final userCredentials = await FirebaseAuth
                                  .instance
                                  .signInWithEmailAndPassword(
                                    email: emailController.text,
                                    password: passwordController.text,
                                  );

                              isAnonymous = false;
                              currentUser = GameUser.fromUid(
                                uid: userCredentials.user!.uid,
                              );
                              _savePrefs(currentUser);

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (final BuildContext context) =>
                                      HomeScreen(),
                                ),
                              );
                            } on FirebaseAuthException catch (e) {
                              if (kDebugMode) {
                                print('error: ${e.code}');
                              }
                            } catch (e) {
                              if (kDebugMode) {
                                print(e);
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(1000, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.circular(8),
                          ),
                          backgroundColor:
                              emailController.text.isEmpty ||
                                  passwordController.text.isEmpty
                              ? Theme.of(context).focusColor
                              : Theme.of(context).primaryColor,
                        ),

                        child: Text(
                          "Sign In",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      // ── Divider ─────────────────────────────────────────
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "or",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),

                      // ── Google Sign-In button ───────────────────────────
                      OutlinedButton(
                        onPressed: _googleLoading ? null : _signInWithGoogle,
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(1000, 40),
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
                                  Image.asset("assets/GoogleG.png"),
                                  SizedBox(width: 10),
                                  Text(
                                    "Continue with Google",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      SizedBox(height: 10),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (final BuildContext context) => Signup(),
                            ),
                          );
                        },
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      GestureDetector(
                        onTap: () {
                          isAnonymous = true;
                          _removePrefs();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (final BuildContext context) =>
                                  HomeScreen(),
                            ),
                          );
                        },
                        child: Text("Enter as a guest"),
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
}
