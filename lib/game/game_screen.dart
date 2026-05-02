import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pacman_application/game/bonus.dart';
import 'package:pacman_application/utils/bonus_type.dart';
import 'package:pacman_application/game/controller/controller.dart';
import 'package:pacman_application/game/controller/retry_button.dart';
import 'package:pacman_application/game/map/game_map.dart';
import 'package:pacman_application/game/ghosts/ghost.dart';
import 'package:pacman_application/game/pacman.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.gameMessege,
    required this.topText,
    required this.controller,
    required this.gameMap,
    required this.pacman,
    required this.getScore,
    required this.getLives,
    required this.getHighScore,
    required this.ghosts,
    required this.bonus,
    required this.dt,
    required this.bonusesTaken,
    required this.retryButton,
    required this.isGameOver,
  });

  final Widget Function(double tileSize) gameMessege;
  final String Function() topText;
  final Controller controller;
  final RetryButton retryButton;
  final bool Function() isGameOver;
  final Pacman pacman;
  final List<Ghost> ghosts;
  final Bonus bonus;
  final List<BonusType> bonusesTaken;
  final GameMap gameMap;
  final int Function() getScore;
  final int Function() getLives;
  final int Function() getHighScore;
  final double dt;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Timer? _timer;
  double time = 0;

  Color? customPacmanColor;
  Color? customBlinkyColor;
  Color? customPinkyColor;
  Color? customInkyColor;
  Color? customClydeColor;
  Color? customMapColor;

  @override
  void initState() {
    super.initState();

    getColors();

    _timer = Timer.periodic(
      Duration(milliseconds: (widget.dt * 1000).round()),
      (timer) {
        time += widget.dt;
        setState(() {});
      },
    );
  }

  void getColors() async {
    final prefs = await SharedPreferences.getInstance();

    var a = prefs.getInt("pacmanColor/a");
    var r = prefs.getInt("pacmanColor/r");
    var g = prefs.getInt("pacmanColor/g");
    var b = prefs.getInt("pacmanColor/b");

    if (a == null || r == null || g == null || b == null) {
      return;
    }

    customPacmanColor = Color.fromARGB(a, r, g, b);

    a = prefs.getInt("blinkyColor/a");
    r = prefs.getInt("blinkyColor/r");
    g = prefs.getInt("blinkyColor/g");
    b = prefs.getInt("blinkyColor/b");

    if (a == null || r == null || g == null || b == null) {
      return;
    }

    customBlinkyColor = Color.fromARGB(a, r, g, b);

    a = prefs.getInt("pinkyColor/a");
    r = prefs.getInt("pinkyColor/r");
    g = prefs.getInt("pinkyColor/g");
    b = prefs.getInt("pinkyColor/b");

    if (a == null || r == null || g == null || b == null) {
      return;
    }

    customPinkyColor = Color.fromARGB(a, r, g, b);

    a = prefs.getInt("inkyColor/a");
    r = prefs.getInt("inkyColor/r");
    g = prefs.getInt("inkyColor/g");
    b = prefs.getInt("inkyColor/b");

    if (a == null || r == null || g == null || b == null) {
      return;
    }

    customInkyColor = Color.fromARGB(a, r, g, b);

    a = prefs.getInt("clydeColor/a");
    r = prefs.getInt("clydeColor/r");
    g = prefs.getInt("clydeColor/g");
    b = prefs.getInt("clydeColor/b");

    if (a == null || r == null || g == null || b == null) {
      return;
    }

    customClydeColor = Color.fromARGB(a, r, g, b);

    a = prefs.getInt("mapColor/a");
    r = prefs.getInt("mapColor/r");
    g = prefs.getInt("mapColor/g");
    b = prefs.getInt("mapColor/b");

    if (a == null || r == null || g == null || b == null) {
      return;
    }

    customMapColor = Color.fromARGB(a, r, g, b);

    setState(() {});
  }

  Color? getColorByGhostName(String name) {
    return switch (name) {
      "Blinky" => customBlinkyColor,
      "Pinky" => customPinkyColor,
      "Inky" => customInkyColor,
      "Clyde" => customClydeColor,
      _ => null,
    };
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final availableWidth = screenSize.width;
    final availableHeight = screenSize.height;
    double tileSize = availableWidth / widget.gameMap.kCols;
    if (tileSize * widget.gameMap.kRows > availableHeight) {
      tileSize = availableHeight / widget.gameMap.kRows;
    }
    final mazeWidth = tileSize * widget.gameMap.kCols;
    final mazeHeight = tileSize * widget.gameMap.kRows;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20,
          children: [
            buildHUD(),

            Stack(
              children: [
                Center(
                  child: Image.asset(
                    widget.gameMap.mapAssetPath,
                    width: mazeWidth,
                    height: mazeHeight,
                    fit: BoxFit.fill,
                    color: customMapColor,
                  ),
                ),

                // ClipRect(
                //   child: CustomPaint(
                //     painter: MazePainter(gameMap: widget.gameMap),
                //     size: Size(mazeWidth, mazeHeight),
                //   ),
                // ),

                widget.gameMessege(tileSize),

                ...widget.gameMap.dots.map((dot) => dot.showOnStack(tileSize)),
                ...widget.gameMap.superPoints.map(
                  (superDot) => superDot.showOnStack(tileSize),
                ),
                ...widget.ghosts.map(
                  (ghost) => ghost.getSprite(
                    tileSize,
                    color: getColorByGhostName(ghost.name),
                  ),
                ),
                widget.pacman.getSprite(tileSize, color: customPacmanColor),
                widget.pacman.nextDirectionArrow(
                  tileSize,
                  color: customPacmanColor,
                ),
                widget.bonus.getSprite(tileSize),
              ],
            ),

            buildBonusArea(widget.bonusesTaken),

            // const Spacer(),
            widget.isGameOver() ? widget.retryButton : widget.controller,
          ],
        ),
      ),
    );
  }

  Widget buildHUD() {
    return Container(
      height: 50,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        spacing: 40,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "SCORE",
                style: TextStyle(
                  fontFamily: "PressStart",
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                widget.getScore().toString(),
                style: TextStyle(
                  fontFamily: "PressStart",
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "HIGH SCORE",
                style: TextStyle(
                  fontFamily: "PressStart",
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                widget.getHighScore().toString(),
                style: TextStyle(
                  fontFamily: "PressStart",
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          buildLives(widget.getLives() - 1),
          // Text("Lives: ${widget.getLives()}", style: TextStyle(color: Colors.white, fontSize: 20),),
        ],
      ),
    );
  }

  Widget buildLives(int lives) {
    Image image = Image.asset("assets/game/pacman.png");
    if (lives > 0) {
      return Column(
        spacing: 1,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(
          min((lives / 3).ceil(), 3),
          (livesRow) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              min(lives - (livesRow) * 3, 3),
              (currentRow) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: image,
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox(width: 50);
  }

  Widget buildBonusArea(List<BonusType> bonuses) => Padding(
    padding: const EdgeInsets.all(2.0),
    child: bonuses.isNotEmpty
        ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: bonuses
                .map(
                  (bonusType) => Image.asset(
                    "${Bonus.bonusAssetsPath}${bonusType.name}${Bonus.bonusesAssetsEndFile}",
                  ),
                )
                .toList()
                .sublist(0, min(8, bonuses.length)),
          )
        : SizedBox(height: 5),
  );
}
