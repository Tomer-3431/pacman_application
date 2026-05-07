import 'package:flutter/material.dart';

const String assetsPath = "assets/game/characters/";
const String endFile = ".png";

class SpriteAnimation {
  SpriteAnimation({
    required this.characterName,
    required this.animationName,
    required this.spritesAmount,
    this.isLoop = false,
    this.frameSpeed = 1 / 8,
  }) {
    for (int i = 0; i < spritesAmount; i++) {
      path.add(
        "$assetsPath${characterName.toLowerCase()}/$animationName/${characterName.toLowerCase()}_${animationName}_$i$endFile",
      );
    }
  }

  final String characterName;
  final String animationName;
  List<String> path = [];

  final int spritesAmount;
  double clock = 0;
  double elapsed = 0;
  int currentIndex = 0;
  final bool isLoop;
  bool paused = false;
  bool done = false;
  bool started = false;

  final double frameSpeed;

  Image getImage({Color? color}) {
    return Image.asset(path[currentIndex], color: color,);
  }

  void update(double dt) {
    if (paused) return;

    clock += dt;
    elapsed += dt;

    if (done) return;

    if (!started) {
      started = true;
    }

    while (clock >= frameSpeed) {
      if (currentIndex + 1 == spritesAmount) {
        if (isLoop) {
          clock -= frameSpeed;
          currentIndex = 0;
        } else {
          done = true;
          return;
        }
      } else {
        clock -= frameSpeed;
        currentIndex++;
      }
    }
  }

  void idle() {
    started = false;
    done = false;
    clock = 0;
    elapsed = 0;
    currentIndex = 0;
  }
}