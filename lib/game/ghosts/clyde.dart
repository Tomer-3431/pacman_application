import 'dart:math';
import 'package:pacman_application/game/animation/sprite_animation.dart';
import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/ghosts/ghost.dart';
import 'package:pacman_application/util.dart';

class Clyde extends Ghost {
  @override
  String name = "Clyde";

  @override
  Direction currentDirection = Direction.left;

  @override
  Direction nextDirection = Direction.left;

  @override
  double x = 14;
  
  @override
  double y = 14;

  @override
  (int x, int y) startingPosition = (14, 14);

  @override
  SpriteAnimation get idle => right;

  @override
  void chase(double dt, double pacmanX, double pacmanY, Direction pacmanDirection) {
    var target = scatterLocation;
    if (dist(pacmanX - x, pacmanY - y) >= 8) {
      target = (pacmanX.round(), pacmanY.round());
    } 
    var direction = ghostChase(target.$1, target.$2, x.round(), y.round(), getGameMap());
    if (direction != null) {
      nextDirection = direction;
    }

    if (nextDirection != currentDirection && !getGameMap().isWall(x.round(), y.round(), nextDirection)) {
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
  late (int, int) scatterLocation = (1, getGameMap().map.length - 2);

  Clyde({required super.gameManager, super.onDeath, super.onEaten});
}