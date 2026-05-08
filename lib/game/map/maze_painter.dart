import 'package:flutter/material.dart';
import 'package:pacman_application/game/map/game_map.dart';

/// A [CustomPainter] that iterates over every cell in [gameMap] and draws the
/// appropriate shape and colour for each tile type.
///
/// Tile-type constants are defined in [GameMap] (e.g. [GameMap.kWall],
/// [GameMap.kSmallDot]). Unknown tile values are silently ignored.
///
/// This painter is declared `const`-constructible and never repaints once the
/// initial frame is drawn ([shouldRepaint] always returns `false`). If the map
/// can change at runtime, override [shouldRepaint] to compare old and new
/// [GameMap] instances.
class MazePainter extends CustomPainter {
  /// Creates a [MazePainter] for the given [gameMap].
  const MazePainter({required this.gameMap});

  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------

  /// The game map whose tiles will be painted onto the canvas.
  final GameMap gameMap;

  // ---------------------------------------------------------------------------
  // Paint colours (private constants for readability)
  // ---------------------------------------------------------------------------

  static const Color _wallColor = Colors.blue;
  static const Color _smallDotColor = Colors.yellow;
  static const Color _superDotColor = Colors.red;
  static const Color _bonusColor = Colors.green;
  static const Color _tunnelColor = Colors.purple;
  static const Color _ghostHouseDoorColor = Colors.orange;
  static const Color _ghostHouseInteriorColor = Colors.grey;
  static const Color _startingPositionColor = Colors.white;

  // ---------------------------------------------------------------------------
  // CustomPainter overrides
  // ---------------------------------------------------------------------------

  /// Paints every tile in [gameMap] onto [canvas] using the given [size].
  ///
  /// The canvas is divided into a uniform grid where each cell is
  /// `size.width / gameMap.kCols` logical pixels wide and tall.
  @override
  void paint(Canvas canvas, Size size) {
    final double tileSize = size.width / gameMap.kCols;

    for (int row = 0; row < gameMap.kRows; row++) {
      for (int col = 0; col < gameMap.kCols; col++) {
        _paintTile(canvas, row: row, col: col, tileSize: tileSize);
      }
    }
  }

  /// Returns `false` because the map is treated as immutable after the first
  /// paint. Override this if dynamic map updates are required.
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Draws the tile at ([row], [col]) according to its value in [gameMap.map].
  void _paintTile(
    Canvas canvas, {
    required int row,
    required int col,
    required double tileSize,
  }) {
    final int tileValue = gameMap.map[row][col];

    // Pixel origin of this tile.
    final double left = col * tileSize;
    final double top = row * tileSize;

    // Centre point of this tile, used for circles.
    final Offset center = Offset(left + tileSize / 2, top + tileSize / 2);

    switch (tileValue) {
      case GameMap.kEmpty:
        // Nothing to draw.
        break;

      case GameMap.kWall:
        _drawRect(canvas, left: left, top: top, tileSize: tileSize, color: _wallColor);

      case GameMap.kSmallDot:
        _drawCircle(canvas, center: center, radius: tileSize / 6, color: _smallDotColor);

      case GameMap.kSuperDot:
        _drawCircle(canvas, center: center, radius: tileSize / 3, color: _superDotColor);

      case GameMap.kBonus:
        _drawCircle(canvas, center: center, radius: tileSize / 4, color: _bonusColor);

      case GameMap.kTunnel:
        _drawRect(canvas, left: left, top: top, tileSize: tileSize, color: _tunnelColor);

      case GameMap.kGhostHouseDoor:
        _drawRect(canvas, left: left, top: top, tileSize: tileSize, color: _ghostHouseDoorColor);

      case GameMap.kGhostHouseInterior:
        _drawRect(canvas, left: left, top: top, tileSize: tileSize, color: _ghostHouseInteriorColor);

      case GameMap.kStartingPosition:
        _drawCircle(canvas, center: center, radius: tileSize / 2, color: _startingPositionColor);

      default:
        // Unknown tile type — ignore silently.
        break;
    }
  }

  /// Draws a filled rectangle covering one tile at ([left], [top]).
  void _drawRect(
    Canvas canvas, {
    required double left,
    required double top,
    required double tileSize,
    required Color color,
  }) {
    canvas.drawRect(
      Rect.fromLTWH(left, top, tileSize, tileSize),
      Paint()..color = color,
    );
  }

  /// Draws a filled circle centred at [center] with the given [radius].
  void _drawCircle(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    canvas.drawCircle(center, radius, Paint()..color = color);
  }
}