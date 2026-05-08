import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacman_application/database/session.dart';
import 'package:pacman_application/utils/bonus_type.dart';
import 'package:pacman_application/game/game_manager.dart';
import 'package:pacman_application/screens/home_screen.dart';

/// Hosts and manages a live Pac-Man game session.
///
/// Responsibilities:
/// - Creates and initialises a [GameManager] for the current game.
/// - Pre-creates the next [GameManager] so a retry starts instantly.
/// - Wires up game-event callbacks: [_onGameOver], [_onRetry], [_onExit],
///   and [_onBonusCollected].
/// - Persists high-score and collectable updates back to [currentUser] for
///   authenticated players.
class GameDisplayer extends StatefulWidget {
  const GameDisplayer({super.key});

  @override
  State<GameDisplayer> createState() => GameDisplayerState();
}

class GameDisplayerState extends State<GameDisplayer> {
  // ── Fields ───────────────────────────────────────────────────────────────

  /// The [GameManager] running the current game session.
  late GameManager _gameManager;

  /// A fully-constructed [GameManager] ready to start the moment the player
  /// requests a retry, eliminating any initialisation delay.
  late GameManager _nextGame;

  /// Audio player used by the game (currently stopped on entry so the home
  /// screen music does not overlap).
  final AudioPlayer _audioPlayer = AudioPlayer();

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.stop();

    _gameManager = _buildGameManager();
    _nextGame = _buildGameManager();
    _gameManager.initGame();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: _gameManager.currentScreen);

  // ── Private helpers ──────────────────────────────────────────────────────

  /// Factory that creates a [GameManager] with all callbacks bound to this
  /// state. Extracted to avoid duplicating the constructor call.
  GameManager _buildGameManager() => GameManager(
    highScore: () => currentUser.highScore,
    onGameOver: _onGameOver,
    onRetry: _onRetry,
    onExit: _onExit,
    onGettingBonus: _onBonusCollected,
  );

  /// Called by [GameManager] when the game ends with [score].
  ///
  /// Updates [currentUser]'s high score if [score] is a new personal best,
  /// and the player is not in a guest session.
  void _onGameOver(int score) {
    if (score > currentUser.highScore && !isAnonymous) {
      currentUser.highScore = score;
    }
  }

  /// Called by [GameManager] when the player taps "Retry".
  ///
  /// Swaps in the pre-built [_nextGame] as the active session and creates a
  /// fresh replacement ready for the next potential retry.
  void _onRetry() {
    setState(() {
      _gameManager = _nextGame;
      _gameManager.initGame();
      _nextGame = _buildGameManager();
    });
  }

  /// Called by [GameManager] when the player taps "Exit".
  ///
  /// Navigates back to [HomeScreen].
  void _onExit() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  /// Called by [GameManager] when the player collects a bonus of [bonusType].
  ///
  /// Increments the bonus count in [currentUser] for authenticated players.
  void _onBonusCollected(BonusType bonusType) {
    if (!isAnonymous) {
      currentUser.addBonus(bonusType);
    }
  }
}