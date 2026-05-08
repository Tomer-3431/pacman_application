import 'dart:math';

/// Represents the four cardinal movement directions used throughout the game.
enum Direction {
  up,
  down,
  left,
  right;

  /// Returns the direction that is directly opposite to this one.
  Direction opposite() {
    switch (this) {
      case Direction.up:
        return Direction.down;
      case Direction.down:
        return Direction.up;
      case Direction.left:
        return Direction.right;
      case Direction.right:
        return Direction.left;
    }
  }

  /// Returns the (dx, dy) grid delta for one step in this direction.
  (int, int) toDelta() {
    switch (this) {
      case Direction.up:
        return (0, -1);
      case Direction.down:
        return (0, 1);
      case Direction.left:
        return (-1, 0);
      case Direction.right:
        return (1, 0);
    }
  }

  /// Returns the rotation angle in radians for rendering a sprite facing this direction.
  ///
  /// Assumes the base sprite points upward (0 radians).
  double toAngle() => switch (this) {
    Direction.up => 0,
    Direction.down => pi,
    Direction.left => -pi / 2,
    Direction.right => pi / 2,
  };
}