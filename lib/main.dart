import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pacman_application/utils/constants.dart';
import 'package:pacman_application/screens/login.dart';
import 'package:pacman_application/database/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
 
/// Bootstraps the application:
/// 1. Ensures Flutter widget binding is initialized.
/// 2. Initializes Firebase with the platform-specific [DefaultFirebaseOptions].
/// 3. Warms up the [SharedPreferences] singleton.
/// 4. Runs [MyApp] as the root widget.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SharedPreferences.getInstance();
 
  runApp(const MyApp());
}
 
/// Root widget of the Pac-Man application.
///
/// Configures the global [MaterialApp] with the app title, theme (including
/// the custom "BJCree" font and a Pac-Man–yellow seed color), and sets
/// [Login] as the initial route.
class MyApp extends StatelessWidget {
  /// Creates the root application widget.
  const MyApp({super.key});
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pac-Man',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'BJCree',
        colorScheme: ColorScheme.fromSeed(seedColor: pacmanColor),
      ),
      home: const Login(),
    );
  }
}