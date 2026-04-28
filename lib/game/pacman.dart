import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pacman_application/game/animation/animated_character.dart';
import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/game_map.dart';
import 'package:pacman_application/game/animation/sprite_animation.dart';

class Pacman extends AnimatedCharacter {

  @override
  String name = "Pacman";

  @override
  Direction currentDirection = Direction.left;
  @override
  Direction nextDirection = Direction.left;
  @override
  double x = 0;
  @override
  double y = 0;

  double speed = 15;
  double acceleration = 240;
  final double jerk = 500;
  final double maxSpeed = 50;
  final double maxAcceleration = 280;
  final double startSpeed = 30;

  late SpriteAnimation deathAnimation;
  late SpriteAnimation idleAnimation;
  late SpriteAnimation upAnimation;
  late SpriteAnimation rightAnimation;
  late SpriteAnimation downAnimation;
  late SpriteAnimation leftAnimation;

  @override
  late List<SpriteAnimation> animations = [
    deathAnimation,
    idleAnimation,
    upAnimation,
    rightAnimation,
    downAnimation,
    leftAnimation,
  ];

  Pacman({required super.gameManager}) {
    x = getGameMap().startingCol;
    y = getGameMap().startingRow;

    deathAnimation = SpriteAnimation(
      characterName: "pacman",
      animationName: "death",
      spritesAmount: 12,
      isLoop: false,
    );
    idleAnimation = SpriteAnimation(
      characterName: "pacman",
      animationName: "idle",
      spritesAmount: 1,
      isLoop: true,
    );
    upAnimation = SpriteAnimation(
      characterName: "pacman",
      animationName: "up",
      spritesAmount: 3,
      isLoop: true,
    );
    rightAnimation = SpriteAnimation(
      characterName: "pacman",
      animationName: "right",
      spritesAmount: 3,
      isLoop: true,
    );
    downAnimation = SpriteAnimation(
      characterName: "pacman",
      animationName: "down",
      spritesAmount: 3,
      isLoop: true,
    );
    leftAnimation = SpriteAnimation(
      characterName: "pacman",
      animationName: "left",
      spritesAmount: 3,
      isLoop: true,
    );
    currentAnimation = deathAnimation;
  }

  @override
  void updateAnimation(double dt) {
    currentAnimation = switch (currentDirection) {
      Direction.up => upAnimation,
      Direction.down => downAnimation,
      Direction.left => leftAnimation,
      Direction.right => rightAnimation,
    };

    for (var animation in animations) {
      if (animation != currentAnimation) {
        animation.idle();
      } else {
        animation.update(dt);
      }
    }
  }

  @override
  void move(double dt) {
    if (currentDirection != nextDirection && !getGameMap().isWall(x.round(), y.round(), nextDirection, isPacman: true)) {
      x = x.roundToDouble();
      y = y.roundToDouble();
      currentDirection = nextDirection;
    }

    if (getGameMap().isWall(
      x.round(),
      y.round(),
      currentDirection,
      isPacman: true,
    )) {
      // speed = startSpeed;
      acceleration = 100;
      x = x.roundToDouble();
      y = y.roundToDouble();
      return;
    }
    acceleration = min(acceleration + jerk * dt, maxAcceleration);
    // speed = min(speed + acceleration * dt, maxSpeed);

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

    if (getGameMap().map[y.round()][x.round()] == GameMap.kTunnel) {
      if (x < 1) {
        x = getGameMap().kCols - 2.01;
      } else if (x > getGameMap().kCols - 2) {
        x = 1.01;
      }
    }
  }

  @override
  void reset() {
    x = getGameMap().startingCol;
    y = getGameMap().startingRow;
    currentDirection = Direction.left;
    nextDirection = Direction.left;
    // speed = 40;
    acceleration = 240;
  }

  Widget nextDirectionArrow(double tileSize) {
    return Positioned(
      left: (x + nextDirection.toDelta().$1) * tileSize,
      top: (y + nextDirection.toDelta().$2) * tileSize,
      child: Transform.rotate(angle: nextDirection.toAngle() ,child: Icon(Icons.arrow_drop_up_sharp, color: Colors.yellow, size: tileSize)),
    );
  }

  void playDeath() {
    currentAnimation = deathAnimation;
  }

  void updateDeathAnimation(double dt) {
    currentAnimation.update(dt);
  }
}
