
import 'package:flutter/material.dart';
import 'package:pacman_application/game/map/game_map.dart';

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