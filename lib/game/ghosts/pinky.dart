import 'package:pacman_application/game/animation/sprite_animation.dart';
import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/ghosts/ghost.dart';

class Pinky extends Ghost {
  @override
  String name = "Pinky";

  @override
  Direction currentDirection = Direction.left;

  @override
  Direction nextDirection = Direction.left;

  @override
  double x = 13;

  @override
  double y = 14;

  @override
  SpriteAnimation get idle => down;

  Pinky({required super.gameManager, super.onDeath, super.onEaten});

  @override
  (int x, int y) startingPosition = (13, 14);

  @override
  void chase(
    double dt,
    double pacmanX,
    double pacmanY,
    Direction pacmanDirection,
  ) {
    hasStartedFrightenedMode = false;
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
    var direction = ghostChase(
      pacmanX.round() + i * pacmanDirection.toDelta().$1,
      pacmanY.round() + i * pacmanDirection.toDelta().$2,
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

  @override
  (int, int) scatterLocation = (1, 1);
}
