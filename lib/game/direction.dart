import 'dart:math';

import 'package:flutter/material.dart';

enum Direction {
  up,
  down,
  left,
  right;

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

  double toAngle() => switch (this) {
    Direction.up => 0,
    Direction.down => pi,
    Direction.left => -pi / 2,
    Direction.right => pi / 2,
  };
}
