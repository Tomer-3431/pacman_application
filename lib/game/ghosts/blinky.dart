import 'package:pacman_application/game/animation/sprite_animation.dart';
import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/ghosts/ghost.dart';

/// Blinky (the red ghost) — the most aggressive chaser.
///
/// Chase strategy: targets Pac-Man's exact current tile.
/// Scatter corner: **top-right** of the maze.
class Blinky extends Ghost {
  /// Creates [Blinky] and registers optional death/eaten callbacks.
  Blinky({required super.gameManager, super.onDeath, super.onEaten});

  // ── Identity ──────────────────────────────────────────────────────────────

  @override
  String name = "Blinky";

  // ── Position ──────────────────────────────────────────────────────────────

  @override
  double x = 13;

  @override
  double y = 11;

  @override
  (int x, int y) startingPosition = (13, 11);

  // ── Direction ─────────────────────────────────────────────────────────────

  @override
  Direction currentDirection = Direction.left;

  @override
  Direction nextDirection = Direction.left;

  // ── Animation ─────────────────────────────────────────────────────────────

  @override
  SpriteAnimation get idleAnimation => up;

  // ── Scatter corner ────────────────────────────────────────────────────────

  @override
  late (int, int) scatterLocation = (getGameMap().map.first.length - 1, 1);

  // ── Chase behaviour ───────────────────────────────────────────────────────

  /// Targets Pac-Man's current tile directly via BFS.
  @override
  void chase(
    double dt,
    double pacmanX,
    double pacmanY,
    Direction pacmanDirection,
  ) {
    hasStartedFrightenedMode = false;

    final direction = ghostChase(
      pacmanX.round(),
      pacmanY.round(),
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