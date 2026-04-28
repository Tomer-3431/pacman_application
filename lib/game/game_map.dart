import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pacman_application/game/controller/controller.dart';
import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/dot.dart';
import 'package:pacman_application/game/super_dot.dart';

class GameMap {
  GameMap({
    required this.map,
    required this.onDotEaten,
    required this.onSuperDotEaten,
  }) {
    init();
  }

  List<List<int>> map;

  static const int kEmpty = 0;
  static const int kWall = 1;
  static const int kSmallDot = 2;
  static const int kSuperDot = 3;
  static const int kBonus = 4;
  static const int kTunnel = 5;
  static const int kGhostHouseDoor = 6;
  static const int kGhostHouseInterior = 7;
  static const int kStartingPosition = 8;

  final String mapAssetPath = 'assets/game/map/map.png';

  final int kCols = 28;
  final int kRows = 31;

  final double startingCol = 13.5;
  final double startingRow = 23;

  final int ghostHouseX = 14;
  final int ghostHouseY = 15;

  final double bonusX = 13.5;
  final double bonusY = 17;

  late final List<Dot> dots = [];
  late final List<SuperDot> superPoints = [];

  final void Function() onDotEaten;
  final void Function() onSuperDotEaten;

  late int leftDots = dots.length + superPoints.length;

  void init() {
    for (int row = 0; row < kRows; row++) {
      for (int col = 0; col < kCols; col++) {
        if (map[row][col] == kSmallDot) {
          dots.add(
            Dot(
              col,
              row,
              onEaten: () {
                onDotEaten();
                leftDots--;
              },
            ),
          );
        } else if (map[row][col] == kSuperDot) {
          superPoints.add(
            SuperDot(
              col,
              row,
              onEaten: () {
                onSuperDotEaten();
                leftDots--;
              },
            ),
          );
        }
      }
    }
  }

  void reset() {
    dots.forEach((dot) => dot.reset());
    superPoints.forEach((superDot) => superDot.reset());
    leftDots = dots.length + superPoints.length;
  }

  bool isWall(int col, int row, Direction direction, {bool isPacman = false}) {
    int targetCol = col;
    int targetRow = row;
    switch (direction) {
      case Direction.up:
        targetRow -= 1;
        break;
      case Direction.down:
        targetRow += 1;
        break;
      case Direction.left:
        targetCol -= 1;
        break;
      case Direction.right:
        targetCol += 1;
        break;
    }
    if (targetCol < 0 ||
        targetCol >= kCols ||
        targetRow < 0 ||
        targetRow >= kRows) {
      return true; // Treat out of bounds as walls
    }

    return map[targetRow][targetCol] == kWall ||
        (isPacman &&
            map[targetRow][targetCol] == kGhostHouseDoor &&
            direction != Direction.up);
  }
}

class mapPallet extends StatelessWidget {
  const mapPallet({super.key, required this.gameMap});

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

class MazePainter extends CustomPainter {
  const MazePainter({required this.gameMap});

  final GameMap gameMap;

  @override
  void paint(Canvas canvas, Size size) {
    final tileSize = size.width / gameMap.kCols;
    for (int row = 0; row < gameMap.kRows; row++) {
      for (int col = 0; col < gameMap.kCols; col++) {
        final tileValue = gameMap.map[row][col];
        switch (tileValue) {
          case GameMap.kEmpty:
            break;
          case GameMap.kWall:
            Paint wallPaint = Paint()..color = Colors.blue;
            canvas.drawRect(
              Rect.fromLTWH(col * tileSize, row * tileSize, tileSize, tileSize),
              wallPaint,
            );
            break;
          case GameMap.kSmallDot:
            Paint pointPaint = Paint()..color = Colors.yellow;
            canvas.drawCircle(
              Offset(
                col * tileSize + tileSize / 2,
                row * tileSize + tileSize / 2,
              ),
              tileSize / 6,
              pointPaint,
            );
            break;
          case GameMap.kSuperDot:
            Paint superPointPaint = Paint()..color = Colors.red;
            canvas.drawCircle(
              Offset(
                col * tileSize + tileSize / 2,
                row * tileSize + tileSize / 2,
              ),
              tileSize / 3,
              superPointPaint,
            );
            break;
          case GameMap.kBonus:
            Paint bonusPaint = Paint()..color = Colors.green;
            canvas.drawCircle(
              Offset(
                col * tileSize + tileSize / 2,
                row * tileSize + tileSize / 2,
              ),
              tileSize / 4,
              bonusPaint,
            );
            break;
          case GameMap.kTunnel:
            Paint tunnelPaint = Paint()..color = Colors.purple;
            canvas.drawRect(
              Rect.fromLTWH(col * tileSize, row * tileSize, tileSize, tileSize),
              tunnelPaint,
            );
            break;
          case GameMap.kGhostHouseDoor:
            Paint ghostHouseDoorPaint = Paint()..color = Colors.orange;
            canvas.drawRect(
              Rect.fromLTWH(col * tileSize, row * tileSize, tileSize, tileSize),
              ghostHouseDoorPaint,
            );
            break;
          case GameMap.kGhostHouseInterior:
            Paint ghostHouseInteriorPaint = Paint()..color = Colors.grey;
            canvas.drawRect(
              Rect.fromLTWH(col * tileSize, row * tileSize, tileSize, tileSize),
              ghostHouseInteriorPaint,
            );
            break;
          case GameMap.kStartingPosition:
            Paint startingPositionPaint = Paint()..color = Colors.white;
            canvas.drawCircle(
              Offset(
                col * tileSize + tileSize / 2,
                row * tileSize + tileSize / 2,
              ),
              tileSize / 2,
              startingPositionPaint,
            );
            break;
          default:
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
