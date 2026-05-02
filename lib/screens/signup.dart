import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pacman_application/constants.dart';
import 'package:pacman_application/database/game_user.dart';
import 'package:pacman_application/utils/bonus_type.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/screens/login.dart';
import 'package:pacman_application/database/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<StatefulWidget> createState() => SignupState();
}

class SignupState extends State<Signup> {
  bool tosValue = false;
  bool _googleLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String messege = '';

  @override
  void dispose() {
    super.dispose();

    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  void _savePrefs(GameUser user) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString("lastUser/uid", user.uid);
    prefs.setString("lastUser/name", user.name);
    prefs.setInt("lastUser/highScore", user.highScore);
    prefs.setString("lastUser/email", user.email);
    await prefs.setString("lastUser/email", user.email);
    for (MapEntry<BonusType, int> entries in user.bonusTable.entries) {
      await prefs.setInt(
        "lastUser/bonusTable/${entries.key.name}",
        entries.value,
      );
    }
  }

  Future<bool> getIsNewUser(String uid) async {
    final ref = FirebaseDatabase.instance.ref("users/$uid");
    return !(await ref.get()).exists;
  }

  // ── Google Sign-Up ──────────────────────────────────────────────────────────
  void _signUpWithGoogle() async {
    if (!tosValue) {
      setState(() => messege = 'Please accept the TOS before continuing.');
      return;
    }

    setState(() {
      _googleLoading = true;
      messege = '';
    });

    try {
      // Opens the Google account picker.
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // User cancelled the picker.
      if (googleUser == null) {
        setState(() => _googleLoading = false);
        return;
      }

      // Exchange for a Firebase credential.
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User firebaseUser = userCredential.user!;

      // Write the user record to the Realtime Database (same schema as
      // email/password sign-up). Only write on first sign-in so we don't
      // overwrite an existing high-score.
      if (await getIsNewUser(firebaseUser.uid)) {
        final DatabaseReference ref = FirebaseDatabase.instance.ref(
          "users/${firebaseUser.uid}",
        );
        await ref.set({
          "name": firebaseUser.displayName ?? googleUser.displayName ?? '',
          "email": firebaseUser.email ?? googleUser.email,
          "highScore": anonymousHighScore,
          "bonusTable": {
            "apple": 0,
            "bell": 0,
            "cherry": 0,
            "galaxian": 0,
            "key": 0,
            "melon": 0,
            "orange": 0,
            "strawberry": 0,
          },
        });
      }

      isAnonymous = false;
      currentUser = GameUser(
        uid: firebaseUser.uid,
        name: firebaseUser.displayName ?? googleUser.displayName ?? '',
        highScore: anonymousHighScore,
        email: firebaseUser.email ?? googleUser.email,
        bonusTable: anonymousBonusTable,
      );
      _savePrefs(currentUser);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Google sign-up Firebase error: ${e.code}');
      setState(() => messege = e.code);
    } catch (e) {
      if (kDebugMode) print('Google sign-up error: $e');
      setState(() => messege = 'something-went-wrong');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: Appbar(
      context: context,
      header: Text("SIGN UP", style: headerTextStyle),
      canLogout: false,
    ),
    body: SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            SizedBox(height: 100),

            Text(
              "Enter these fields the make an account on the app",
              style: TextStyle(fontSize: 12, color: Colors.grey[800]),
            ),

            SizedBox(height: 20),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                TextField(
                  controller: nameController,
                  onSubmitted: (text) => setState(() {}),
                ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Email",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  onSubmitted: (value) => setState(() {}),
                ),
              ],
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Password",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                TextField(
                  obscureText: true,
                  controller: passwordController,
                  onSubmitted: (value) => setState(() {}),
                ),
              ],
            ),

            SizedBox(height: 15),

            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     Text(
            //       "Or Sign up using Google",
            //       style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            //     ),

            //     GoogleSignIn.instance.supportsAuthenticate()
            //         ? ElevatedButton(
            //             onPressed: () async {
            //               try {
            //                 var user = await signInWithGoogle();
            //                 print(user);
            //               } catch (e) {
            //                 print(e.toString());
            //               }
            //             },
            //             child: const Text("SIGN IN"),
            //           )
            //         : Container(),
            //   ],
            // ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: tosValue,
                  onChanged: (value) {
                    setState(() {
                      tosValue = value ?? false;
                    });
                  },
                ),
                Text("I agree to the TOS and Privacy Policy"),
              ],
            ),

            ElevatedButton(
              onPressed: () async {
                if (tosValue) {
                  try {
                    final creds = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );
                    creds.user!.updateDisplayName(nameController.text);
                    DatabaseReference ref = FirebaseDatabase.instance.ref(
                      "users/${creds.user!.uid}",
                    );
                    await ref.set({
                      "name": nameController.text,
                      "email": emailController.text,
                      "highScore": anonymousHighScore,
                      "bonusTable": {
                        "apple": 0,
                        "bell": 0,
                        "cherry": 0,
                        "galaxian": 0,
                        "key": 0,
                        "melon": 0,
                        "orange": 0,
                        "strawberry": 0,
                      },
                    });

                    isAnonymous = false;
                    currentUser = GameUser(
                      uid: creds.user!.uid,
                      name: nameController.text,
                      highScore: anonymousHighScore,
                      email: emailController.text,
                      bonusTable: anonymousBonusTable,
                    );
                    _savePrefs(currentUser);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  } on FirebaseAuthException catch (e) {
                    if (kDebugMode) {
                      print(e.code);
                    }
                    setState(() {
                      messege = e.code;
                    });
                  } on FirebaseException catch (e) {
                    if (kDebugMode) {
                      print(e.code);
                    }
                    setState(() {
                      messege = e.code;
                    });
                  } catch (e) {
                    if (kDebugMode) {
                      print(e);
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                enableFeedback: tosValue,
                minimumSize: Size(1000, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(8),
                ),
                backgroundColor:
                    nameController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        passwordController.text.isEmpty ||
                        !tosValue
                    ? Theme.of(context).focusColor
                    : Theme.of(context).primaryColor,
              ),

              child: Text("Continue", style: TextStyle(color: Colors.white)),
            ),

            // ── Divider ────────────────────────────────────────────
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade300)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "or",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade300)),
              ],
            ),

            // ── Google Sign-Up button ──────────────────────────────
            OutlinedButton(
              onPressed: _googleLoading ? null : _signUpWithGoogle,
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
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                      ],
                    ),
            ),

            // ── Sign In link ───────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Have an Account?  ",
                  style: TextStyle(color: Colors.grey),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (final BuildContext context) => Login(),
                      ),
                    );
                  },
                  child: Text(
                    "Sign In",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),

            SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    messege.toUpperCase(),
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: "PressStart",
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
