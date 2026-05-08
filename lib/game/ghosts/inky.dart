import 'package:pacman_application/game/animation/sprite_animation.dart';
import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/ghosts/ghost.dart';

/// Inky (the cyan ghost) — the flanker.
///
/// Chase strategy: combines Blinky's position and a point ahead of Pac-Man
/// to produce a flanking target.
///
/// Algorithm:
/// 1. Find a "pivot" up to 4 tiles ahead of Pac-Man (wall-limited).
/// 2. Draw a vector from Blinky's position to the pivot.
/// 3. Double that vector to get Inky's target tile.
///
/// Scatter corner: **bottom-right** of the maze.
class Inky extends Ghost {
  /// Creates [Inky] and registers optional death/eaten callbacks.
  Inky({required super.gameManager, super.onDeath, super.onEaten});

  // ── Identity ──────────────────────────────────────────────────────────────

  @override
  String name = "Inky";

  // ── Position ──────────────────────────────────────────────────────────────

  @override
  double x = 12;

  @override
  double y = 14;

  @override
  (int x, int y) startingPosition = (12, 14);

  // ── Direction ─────────────────────────────────────────────────────────────

  @override
  Direction currentDirection = Direction.left;

  @override
  Direction nextDirection = Direction.left;

  // ── Animation ─────────────────────────────────────────────────────────────

  @override
  SpriteAnimation get idleAnimation => left;

  // ── Scatter corner ────────────────────────────────────────────────────────

  @override
  late (int, int) scatterLocation = (
    getGameMap().map.first.length - 1,
    getGameMap().map.length - 1,
  );

  // ── Blinky position feed (static, updated by GameManager each tick) ───────

  /// Blinky's most recent tile position, injected by [GameManager] every tick.
  ///
  /// Kept static so [Inky] can read Blinky's position without a direct
  /// reference to the [Blinky] instance.
  static var blinkyPosition = (0.0, 0.0);

  /// Updates [blinkyPosition] with the current tile coordinates of Blinky.
  static void setBlinkyPosition(double x, double y) {
    blinkyPosition = (x, y);
  }

  // ── Chase behaviour ───────────────────────────────────────────────────────

  /// Targets a tile computed from Blinky's position and Pac-Man's heading.
  @override
  void chase(
    double dt,
    double pacmanX,
    double pacmanY,
    Direction pacmanDirection,
  ) {
    // Find the pivot: up to 4 tiles ahead of Pac-Man.
    int steps;
    for (steps = 0; steps < 4; steps++) {
      if (getGameMap().isWall(
        x.round() + steps * pacmanDirection.toDelta().$1,
        y.round() + steps * pacmanDirection.toDelta().$2,
        pacmanDirection,
      )) {
        break;
      }
    }

    final pivot = (
      pacmanX.round() + steps * pacmanDirection.toDelta().$1,
      pacmanY.round() + steps * pacmanDirection.toDelta().$2,
    );

    // Target = 2 × (pivot − blinky), clamped to the map bounds.
    final target = (
      (2 * pivot.$1 - blinkyPosition.$1)
          .clamp(1, getGameMap().kCols - 1)
          .toInt(),
      (2 * pivot.$2 - blinkyPosition.$2)
          .clamp(1, getGameMap().kRows - 1)
          .toInt(),
    );

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