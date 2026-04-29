import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacman_application/database/game_user.dart';
import 'package:pacman_application/database/session.dart';
import 'package:pacman_application/database/signup.dart';
import 'package:pacman_application/home/home_screen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final user = snapshot.data!;
        currentUser = GameUser.fromUid(uid: user.uid);
        // while (!currentUser.haveInitalized());
        return HomeScreen();
      }

      return Scaffold(
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: Column(
              children: [
                SizedBox(height: 150),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      "Hi there! Nice to see you again.",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),

                    SizedBox(height: 15),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text("Email", style: TextStyle(color: Colors.red)),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          onSubmitted: (text) => setState(() {}),
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Password", style: TextStyle(color: Colors.red)),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          onSubmitted: (value) => setState(() {}),
                        ),
                      ],
                    ),

                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   spacing: 10,
                    //   children: [
                    //     Text(
                    //       "Or Sign up using Google",
                    //       style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    //     ),

                    //     GoogleSignIn.instance.supportsAuthenticate()
                    //     ? ElevatedButton(
                    //         onPressed: () async {
                    //           try {
                    //             var user = await signInWithGoogle();
                    //             print(user);
                    //           } on GoogleSignInException catch (e) {
                    //             print(e.code);
                    //           } catch (e) {
                    //             print(e.toString());
                    //           }
                    //         },
                    //         child: const Text("SIGN IN"),
                    //       )
                    //     : Container(),
                    //   ],
                    // ),
                    SizedBox(height: 15),

                    ElevatedButton(
                      onPressed: () async {
                        if (emailController.text.isNotEmpty &&
                            passwordController.text.isNotEmpty) {
                          try {
                            final userCredentials = await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                  email: emailController.text,
                                  password: passwordController.text,
                                );

                            currentUser = GameUser.fromUid(uid: userCredentials.user!.uid);

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
                            ? Colors.deepOrange[100]
                            : Colors.deepOrange,
                      ),

                      child: Text(
                        "Sign In",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),

                    Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.grey),
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
                        style: TextStyle(color: Colors.deepOrange),
                      ),
                    ),

                    SizedBox(height: 10),

                    GestureDetector(
                      onTap: () {
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
      );
    },
  );
}
