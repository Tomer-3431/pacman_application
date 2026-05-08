import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacman_application/utils/constants.dart';
import 'package:pacman_application/database/session.dart';
import 'package:pacman_application/utils/game_displayer.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/utils/sidebar.dart';

/// The main landing screen shown after a successful sign-in.
///
/// Displays the player's avatar and username, their current high score, a
/// circular progress indicator summarising collectable completion, and a
/// "QUICK PLAY" button that launches the game directly.
///
/// Background music loops while this screen is active and is stopped when
/// the player navigates away.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  // ── Fields ───────────────────────────────────────────────────────────────

  /// Fraction of bonus types that the player has collected at least once,
  /// in the range [0, 1]. Drives the [CircularProgressIndicator].
  double _progress = 0;

  /// Audio player that loops the home-screen background track.
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.play(AssetSource('audio/Home_Music.mp3'));

    _computeBonusProgress();
  }

  @override
  void dispose() {
    // Restore portrait orientation when leaving the screen.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // If the user data has not finished loading yet, trigger a rebuild once
    // the async fetch in GameUser.fromUid completes.
    if (!currentUser.haveInitialized()) {
      setState(() {});
    }

    return Scaffold(
      appBar: Appbar(
        context: context,
        header: Text('HOME SCREEN', style: headerTextStyle),
      ),
      drawer: const Sidebar(),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            spacing: 10,
            children: [
              const SizedBox(height: 25),

              // ── Player identity row ────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 10,
                children: [
                  const CircleAvatar(),
                  Text(
                    currentUser.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ── High-score row ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                spacing: 20,
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber[600], size: 80),
                  Text(
                    'Your high score\nis currently ${currentUser.highScore},\ncongratulations!',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ── Collectable progress row ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                spacing: 20,
                children: [
                  Text(
                    'You have collected\n${(_progress * 100).toStringAsFixed(0)}% of all\ncollectables',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CircularProgressIndicator(
                        value: _progress,
                        color: Colors.blue[900],
                        strokeWidth: 10,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // ── Quick Play button ──────────────────────────────────────
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const GameDisplayer()),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: Colors.black, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Icon(
                          Icons.videogame_asset,
                          size: 35,
                          color: Theme.of(context).primaryColor,
                        ),
                        Text(
                          'QUICK PLAY',
                          style: TextStyle(
                            fontSize: 28,
                            fontFamily: 'PacFont',
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  /// Calculates [_progress] as the fraction of distinct bonus types that the
  /// player has collected at least once.
  void _computeBonusProgress() {
    int collectedCount = 0;
    for (final entry in currentUser.bonusTable.entries) {
      if (entry.value > 0) collectedCount++;
    }
    _progress = collectedCount / currentUser.bonusTable.length;
  }
}