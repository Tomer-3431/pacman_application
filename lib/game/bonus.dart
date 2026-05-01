import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pacman_application/utils/bonus_type.dart';
import 'package:pacman_application/game/game_manager.dart';
import 'package:pacman_application/game/pacman.dart';
import 'package:pacman_application/util.dart';

class Bonus {
  String name = "Bonus";
  bool isVisiable = false;
  BonusType currentType = BonusType.cherry;
  late Random random;

  GameManager gameManager;

  double x = 0;
  double y = 0;

  Bonus({required this.gameManager, this.onEaten}) {
    x = gameManager.gameMap.bonusX;
    y = gameManager.gameMap.bonusY;
    random = Random();
    isVisiable = false;
  }

  void Function(BonusType bonusType)? onEaten;

  Pacman getPacman() => gameManager.pacman;

  void update(double dt) {
    if (isVisiable && dist(getPacman().x - x, getPacman().y - y) <= 0.5) {
      onEaten?.call(currentType);
      isVisiable = false;
    }
  }

  void setVisiable() {
    if (!isVisiable) {
      currentType = BonusType.values[random.nextInt(BonusType.values.length)];
    }
    isVisiable = true;
  }

  static const String bonusAssetsPath = "assets/game/bonuses/";
  static const String bonusesAssetsEndFile = ".png";

  Widget getSprite(double tileSize) => Positioned(
    left: x * tileSize,
    top: y * tileSize,
    child: isVisiable
        ? Image.asset(
            "$bonusAssetsPath${currentType.name}$bonusesAssetsEndFile",
          )
        : Container(),
  );
}
