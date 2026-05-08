import 'package:pacman_application/game/animation/sprite_animation.dart';
import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/ghosts/ghost.dart';

/// Pinky (the pink ghost) — the ambusher.
///
/// Chase strategy: targets the tile **4 steps ahead** of Pac-Man's current
/// direction (stopping earlier if a wall is in the way), attempting to
/// cut Pac-Man off at the front.
/// Scatter corner: **top-left** of the maze.
class Pinky extends Ghost {
  /// Creates [Pinky] and registers optional death/eaten callbacks.
  Pinky({required super.gameManager, super.onDeath, super.onEaten});

  // ── Identity ──────────────────────────────────────────────────────────────

  @override
  String name = "Pinky";

  // ── Position ──────────────────────────────────────────────────────────────

  @override
  double x = 13;

  @override
  double y = 14;

  @override
  (int x, int y) startingPosition = (13, 14);

  // ── Direction ─────────────────────────────────────────────────────────────

  @override
  Direction currentDirection = Direction.left;

  @override
  Direction nextDirection = Direction.left;

  // ── Animation ─────────────────────────────────────────────────────────────

  @override
  SpriteAnimation get idleAnimation => down;

  // ── Scatter corner ────────────────────────────────────────────────────────

  @override
  (int, int) scatterLocation = (1, 1);

  // ── Chase behaviour ───────────────────────────────────────────────────────

  /// Targets the tile up to 4 steps ahead of Pac-Man's facing direction.
  ///
  /// Walks forward along Pac-Man's direction until a wall is hit or 4 tiles
  /// have been counted, then uses that tile as the BFS target.
  @override
  void chase(
    double dt,
    double pacmanX,
    double pacmanY,
    Direction pacmanDirection,
  ) {
    hasStartedFrightenedMode = false;

    // Find how far ahead Pac-Man's path is clear (up to 4 tiles).
    int steps;
    for (steps = 0; steps < 4; steps++) {
      if (getGameMap().isWall(
        pacmanX.round() + steps * pacmanDirection.toDelta().$1,
        pacmanY.round() + steps * pacmanDirection.toDelta().$2,
        pacmanDirection,
      )) {
        break;
      }
    }

    final direction = ghostChase(
      pacmanX.round() + steps * pacmanDirection.toDelta().$1,
      pacmanY.round() + steps * pacmanDirection.toDelta().$2,
      x.round(),
      y.round(),
    );
    if (direction != null) nextDirection = direction;

    if (nextDirection != currentDirection &&
        !getGameMap().isWall(x.round(), y.round(), nextDirection)) {
      currentDirection = nextDirection;
      x = x.roundToDouble();
      y = y.roundToDouble();
    }

    if (getGameMap().isWall(x.round(), y.round(), currentDirection)) {
      x = x.roundToDouble();
      y = y.roundToDouble();
      return;
    }

    stepForward(dt);
  }
}