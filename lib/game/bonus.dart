import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pacman_application/utils/bonus_type.dart';
import 'package:pacman_application/game/game_manager.dart';
import 'package:pacman_application/game/pacman.dart';
import 'package:pacman_application/utils/util.dart';

class Bonus {
  final String name = "Bonus";
  bool isVisible = false;
  BonusType currentType = BonusType.cherry;
  late Random random;

  GameManager gameManager;

  double x = 0;
  double y = 0;

  Bonus({required this.gameManager, this.onEaten}) {
    x = gameManager.gameMap.bonusX;
    y = gameManager.gameMap.bonusY;
    random = Random();
    isVisible = false;
  }

  void Function(BonusType bonusType)? onEaten;

  Pacman getPacman() => gameManager.pacman;

  void update(double dt) {
    if (isVisible && dist(getPacman().x - x, getPacman().y - y) <= 0.5) {
      onEaten?.call(currentType);
      isVisible = false;
    }
  }

  void setVisible() {
    if (!isVisible) {
      currentType = BonusType.values[random.nextInt(BonusType.values.length)];
    }
    isVisible = true;
  }

  static const String bonusAssetsPath = "assets/game/bonuses/";
  static const String bonusesAssetsEndFile = ".png";

  Widget getSprite(double tileSize) => Positioned(
    left: x * tileSize,
    top: y * tileSize,
    child: isVisible
        ? Image.asset(
            "$bonusAssetsPath${currentType.name}$bonusesAssetsEndFile",
          )
        : Container(),
  );
}
