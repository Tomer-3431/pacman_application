import 'package:flutter/material.dart';
import 'package:pacman_application/game/map/game_map.dart';
import 'package:pacman_application/game/map/maze_painter.dart';

/// A [StatelessWidget] that lays out the Pac-Man maze.
///
/// The maze is rendered as two stacked layers:
/// 1. A static background PNG (`assets/game sprites/map/map.png`).
/// 2. A [CustomPaint] overlay produced by [MazePainter] that draws all
///    game-tile states (walls, dots, tunnels, ghost house, etc.).
///
/// Both layers are sized to fill as much of the screen as possible while
/// preserving the grid's aspect ratio (determined by [GameMap.kCols] ×
/// [GameMap.kRows]).
class MapPalette extends StatelessWidget {
  /// Creates a [MapPalette] for the given [gameMap].
  const MapPalette({super.key, required this.gameMap});

  // ---------------------------------------------------------------------------
  // Fields
  // ---------------------------------------------------------------------------

  /// The game map data used to compute tile sizes and passed to [MazePainter].
  final GameMap gameMap;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Compute the largest tile size that fits the screen in both dimensions.
    final double tileSize = _computeTileSize(screenSize);

    final double mazeWidth = tileSize * gameMap.kCols;
    final double mazeHeight = tileSize * gameMap.kRows;

    return Stack(
      children: [
        // Layer 1: static background image.
        Center(
          child: Image.asset(
            'assets/game sprites/map/map.png',
            width: mazeWidth,
            height: mazeHeight,
            fit: BoxFit.fill,
          ),
        ),

        // Layer 2: dynamic tile overlay drawn by MazePainter.
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

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Calculates the tile size (in logical pixels) that keeps the entire maze
  /// visible within [screenSize].
  ///
  /// Starts with a width-based tile size, then shrinks it if the resulting
  /// maze height would exceed the available screen height.
  double _computeTileSize(Size screenSize) {
    double tileSize = screenSize.width / gameMap.kCols;
    if (tileSize * gameMap.kRows > screenSize.height) {
      tileSize = screenSize.height / gameMap.kRows;
    }
    return tileSize;
  }
}