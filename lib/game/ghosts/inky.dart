import 'package:pacman_application/game/animation/sprite_animation.dart';
import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/ghosts/ghost.dart';

class Inky extends Ghost {
  @override
  String name = "Inky";

  @override
  Direction currentDirection = Direction.left;

  @override
  Direction nextDirection = Direction.left;

  @override
  double x = 12;

  @override
  double y = 14;

  @override
  (int x, int y) startingPosition = (12, 14);

  @override
  SpriteAnimation get idle => left;

  static var blinkyLocation = (0.0, 0.0);

  @override
  void chase(
    double dt,
    double pacmanX,
    double pacmanY,
    Direction pacmanDirection,
  ) {
    int i;
    for (i = 0; i < 4; i++) {
      if (getGameMap().isWall(
        x.round() + i * pacmanDirection.toDelta().$1,
        y.round() + i * pacmanDirection.toDelta().$2,
        pacmanDirection,
      )) {
        break;
      }
    }
    var pinkyTarget = (
      pacmanX.round() + i * pacmanDirection.toDelta().$1,
      pacmanY.round() + i * pacmanDirection.toDelta().$2,
    );
    var target = (
      (2 * pinkyTarget.$1 - blinkyLocation.$1)
          .clamp(1, getGameMap().kCols - 1)
          .toInt(),
      (2 * pinkyTarget.$2 - blinkyLocation.$2)
          .clamp(1, getGameMap().kRows - 1)
          .toInt(),
    );

    var direction = ghostChase(
      target.$1,
      target.$2,
      x.round(),
      y.round(),
    );
    if (direction != null) {
      nextDirection = direction;
    }

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

    switch (currentDirection) {
      case Direction.up:
        y -= speed * dt;
        break;
      case Direction.down:
        y += speed * dt;
        break;
      case Direction.left:
        x -= speed * dt;
        break;
      case Direction.right:
        x += speed * dt;
        break;
    }
  }

  static void setBlinkyLocation(double x, double y) {
    blinkyLocation = (x, y);
  }

  @override
  late (int, int) scatterLocation = (
    getGameMap().map.first.length - 1,
    getGameMap().map.length - 1,
  );

  Inky({required super.gameManager, super.onDeath, super.onEaten});
}
