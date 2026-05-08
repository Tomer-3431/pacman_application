import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/screens/home_screen.dart';

/// A brief transitional screen displayed while the app navigates to
/// [HomeScreen] after a successful sign-in.
///
/// After 500 ms it automatically replaces itself with [HomeScreen],
/// giving any in-flight data fetches a moment to begin before the
/// home screen is rendered.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {
  // ── Fields ───────────────────────────────────────────────────────────────

  /// Timer that triggers navigation to [HomeScreen] after a short delay.
  late final Timer _timer;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(milliseconds: 500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: Appbar(context: context),
    body: const Center(child: Text('Loading…')),
  );
}