import 'package:flutter/material.dart';
import 'package:pacman_application/game/animation/sprite_animation.dart';
import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/game_manager.dart';
import 'package:pacman_application/game/game_map.dart';
import 'package:pacman_application/game/game_screen.dart';
import 'package:pacman_application/game/pacman.dart';

abstract class AnimatedCharacter {

  AnimatedCharacter({
    required this.gameManager
  });

  GameManager gameManager;

  abstract final String name;

  abstract double x;
  abstract double y;
  abstract Direction currentDirection;
  abstract Direction nextDirection;

  late List<SpriteAnimation> animations = [];
  late SpriteAnimation currentAnimation;

  Widget getSprite(double tileSize) => Positioned(
    left: x * tileSize,
    top: y * tileSize,
    child: currentAnimation.getImage(),
  );

  void move(double dt);

  void updateAnimation(double dt);

  void update(double dt) {
    move(dt);
    updateAnimation(dt);
  }

  GameMap getGameMap() => gameManager.gameMap;

  GameScreen getGameScreen() => gameManager.currentScreen;

  Pacman getPacman() => gameManager.pacman;

  void reset();
}
