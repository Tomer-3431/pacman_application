import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pacman_application/game/bonus.dart';
import 'package:pacman_application/game/controller/controller.dart';
import 'package:pacman_application/game/game_map.dart';
import 'package:pacman_application/game/ghosts/ghost.dart';
import 'package:pacman_application/game/pacman.dart';

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
    required this.ghosts,
    required this.bonus,
    required this.dt,
    required this.bonusesTaken,
  });

  final Widget Function() gameMessege;
  final String Function() topText;
  final Controller controller;
  final Pacman pacman;
  final List<Ghost> ghosts;
  final Bonus bonus;
  final List<BonusType> bonusesTaken;
  final GameMap gameMap;
  final int Function() getScore;
  final int Function() getLives;
  final double dt;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Timer? _timer;
  double time = 0;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(
      Duration(milliseconds: (widget.dt * 1000).round()),
      (timer) {
        time += widget.dt;
        setState(() {});
      },
    );
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
          mainAxisAlignment: MainAxisAlignment.end,
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
                  ),
                ),

                // ClipRect(
                //   child: CustomPaint(
                //     painter: MazePainter(gameMap: widget.gameMap),
                //     size: Size(mazeWidth, mazeHeight),
                //   ),
                // ),
                Positioned(
                  top: tileSize * 16.2,
                  left: tileSize * 10.5,
                  child: widget.gameMessege(),
                ),

                ...widget.gameMap.dots.map((dot) => dot.showOnStack(tileSize)),
                ...widget.gameMap.superPoints.map(
                  (superDot) => superDot.showOnStack(tileSize),
                ),
                ...widget.ghosts.map((ghost) => ghost.getSprite(tileSize)),
                widget.pacman.getSprite(tileSize),
                widget.pacman.nextDirectionArrow(tileSize),
                widget.bonus.getSprite(tileSize),
              ],
            ),

            SizedBox(height: 15, child: buildBonusArea(widget.bonusesTaken)),

            // const Spacer(),
            widget.controller,
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
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 40,
        children: [
          Text(
            widget.getScore().toString(),
            style: TextStyle(fontFamily: "PressStart", color: Colors.white, fontSize: 20),
          ),
          Text(
            widget.topText(),
            style: TextStyle(fontFamily: "PacFont", color: Colors.white, fontSize: 20),
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

  Widget buildBonusArea(List<BonusType> bonuses) => Expanded(
    child: Padding(
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
                      scale: 0.8,
                    ),
                  )
                  .toList()
                  .sublist(0, min(8, bonuses.length)),
            )
          : SizedBox(height: 5),
    ),
  );
}
