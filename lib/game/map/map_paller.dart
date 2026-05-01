
import 'package:flutter/material.dart';
import 'package:pacman_application/game/map/game_map.dart';
import 'package:pacman_application/game/map/maze_painter.dart';

class MapPallet extends StatelessWidget {
  const MapPallet({super.key, required this.gameMap});

  final GameMap gameMap;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final availableWidth = screenSize.width;
    final availableHeight = screenSize.height;
    double tileSize = availableWidth / gameMap.kCols;
    if (tileSize * gameMap.kRows > availableHeight) {
      tileSize = availableHeight / gameMap.kRows;
    }
    final mazeWidth = tileSize * gameMap.kCols;
    final mazeHeight = tileSize * gameMap.kRows;

    return Stack(
      children: [
        Center(
          child: Image.asset(
            'assets/game sprites/map/map.png',
            width: mazeWidth,
            height: mazeHeight,
            fit: BoxFit.fill,
          ),
        ),
        Center(
          child: SizedBox(
            width: mazeWidth,
            height: mazeHeight,
            child: ClipRect(
              child: CustomPaint(
                painter: MazePainter(gameMap: gameMap),
                size: Size(mazeWidth, mazeHeight),
              ),
            ),
          ),
        ),
      ],
    );
  }
}