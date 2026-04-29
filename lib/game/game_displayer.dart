import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacman_application/database/session.dart';
import 'package:pacman_application/game/game_manager.dart';
import 'package:pacman_application/home/home_screen.dart';

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
      onExit: onExit
    );
    newGame = GameManager(
      highScore: () => currentUser.highScore,
      onGameOver: onGameOver,
      onRetry: onRetry,
      onExit: onExit
    );
    _gameManager.initGame();
  }

  void onGameOver(int score) {
    if (score > currentUser.highScore) {
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
        onExit: onExit
      );
    });
  }

  void onExit() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
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
