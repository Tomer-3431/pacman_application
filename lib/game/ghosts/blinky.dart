import 'package:pacman_application/game/animation/sprite_animation.dart';
import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/ghosts/ghost.dart';

class Blinky extends Ghost {

  @override
  String name = "Blinky";

  @override
  Direction currentDirection = Direction.left;

  @override
  Direction nextDirection = Direction.left;

  @override
  double x = 13;

  @override
  double y = 11;

  @override
  SpriteAnimation get idle => up;

  Blinky({required super.gameManager, super.onDeath, super.onEaten});

  @override
  (int x, int y) startingPosition = (13, 11);

  @override
  void chase(
    double dt,
    double pacmanX,
    double pacmanY,
    Direction pacmanDirection,
  ) {
    hasStartedFrightenedMode = false;

    var direction = ghostChase(
      pacmanX.round(),
      pacmanY.round(),
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
  late (int, int) scatterLocation = (getGameMap().map.first.length - 1, 1);
}
