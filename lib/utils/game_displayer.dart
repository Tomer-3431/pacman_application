import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacman_application/database/session.dart';
import 'package:pacman_application/utils/bonus_type.dart';
import 'package:pacman_application/game/game_manager.dart';
import 'package:pacman_application/screens/home_screen.dart';

class GameDisplayer extends StatefulWidget {
  const GameDisplayer({super.key});

  @override
  State<StatefulWidget> createState() => GameDisplayerState();
}

class GameDisplayerState extends State<GameDisplayer> {
  late GameManager _gameManager;
  late GameManager newGame;

  @override
  void initState() {
    super.initState();

    _gameManager = GameManager(
      highScore: () => currentUser.highScore,
      onGameOver: onGameOver,
      onRetry: onRetry,
      onExit: onExit,
      onGettingBonus: onGettingBonus
    );
    newGame = GameManager(
      highScore: () => currentUser.highScore,
      onGameOver: onGameOver,
      onRetry: onRetry,
      onExit: onExit,
      onGettingBonus: onGettingBonus
    );
    _gameManager.initGame();
  }

  void onGameOver(int score) {
    if (score > currentUser.highScore && !isAnonymous) {
      currentUser.highScore = score;
    }
  }

  void onRetry() {
    setState(() {
      _gameManager = newGame;
      _gameManager.initGame();
      newGame = GameManager(
        highScore: () => currentUser.highScore,
        onGameOver: onGameOver,
        onRetry: onRetry,
        onExit: onExit,
        onGettingBonus: onGettingBonus
      );
    });
  }

  void onExit() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void onGettingBonus(BonusType bonusType) {
    if (!isAnonymous) {
      currentUser.bonusTable[bonusType] = currentUser.bonusTable[bonusType]! + 1;
    }
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: _gameManager.currentScreen);
}
