import 'package:pacman_application/game/animation/sprite_animation.dart';
import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/ghosts/ghost.dart';
import 'package:pacman_application/utils/util.dart';

/// Clyde (the orange ghost) — the unpredictable one.
///
/// Chase strategy:
/// - When **8 or more tiles away** from Pac-Man, chases him directly like Blinky.
/// - When **closer than 8 tiles**, retreats to his scatter corner instead,
///   creating an oscillating approach/retreat behaviour.
///
/// Scatter corner: **bottom-left** of the maze.
class Clyde extends Ghost {
  /// Creates [Clyde] and registers optional death/eaten callbacks.
  Clyde({required super.gameManager, super.onDeath, super.onEaten});

  // ── Identity ──────────────────────────────────────────────────────────────

  @override
  String name = "Clyde";

  // ── Position ──────────────────────────────────────────────────────────────

  @override
  double x = 14;

  @override
  double y = 14;

  @override
  (int x, int y) startingPosition = (14, 14);

  // ── Direction ─────────────────────────────────────────────────────────────

  @override
  Direction currentDirection = Direction.left;

  @override
  Direction nextDirection = Direction.left;

  // ── Animation ─────────────────────────────────────────────────────────────

  @override
  SpriteAnimation get idleAnimation => right;

  // ── Scatter corner ────────────────────────────────────────────────────────

  @override
  late (int, int) scatterLocation = (1, getGameMap().map.length - 2);

  // ── Chase behaviour ───────────────────────────────────────────────────────

  /// Chases Pac-Man when ≥ 8 tiles away; retreats to scatter corner when closer.
  @override
  void chase(double dt, double pacmanX, double pacmanY, Direction pacmanDirection) {
    // Choose target: scatter corner if too close, Pac-Man's tile otherwise.
    final target = dist(pacmanX - x, pacmanY - y) >= 8
        ? (pacmanX.round(), pacmanY.round())
        : scatterLocation;

    final direction = ghostChase(target.$1, target.$2, x.round(), y.round());
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