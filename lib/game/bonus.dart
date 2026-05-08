import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pacman_application/utils/bonus_type.dart';
import 'package:pacman_application/game/game_manager.dart';
import 'package:pacman_application/game/pacman.dart';
import 'package:pacman_application/utils/util.dart';

/// The bonus item that periodically appears in the centre of the maze.
///
/// [GameManager] calls [setVisible] via a [GameTimer] to show a randomly
/// chosen [BonusType].  Each [update] tick checks whether Pac-Man has
/// collected it.  The item is hidden again after collection.
class Bonus {
  /// Creates a [Bonus] positioned at the map's bonus tile and hidden by default.
  Bonus({required this.gameManager, this.onEaten}) {
    x = gameManager.gameMap.bonusX;
    y = gameManager.gameMap.bonusY;
  }

  // ── Dependencies ──────────────────────────────────────────────────────────

  /// Reference to the central [GameManager].
  final GameManager gameManager;

  // ── Position ──────────────────────────────────────────────────────────────

  /// Horizontal tile position (set from [GameMap.bonusX] in constructor).
  late double x;

  /// Vertical tile position (set from [GameMap.bonusY] in constructor).
  late double y;

  // ── State ─────────────────────────────────────────────────────────────────

  /// Whether the bonus item is currently shown on screen.
  bool isVisible = false;

  /// The [BonusType] currently displayed (randomised each time [setVisible] is called).
  BonusType currentType = BonusType.cherry;

  // ── Callbacks ─────────────────────────────────────────────────────────────

  /// Called when Pac-Man collects the bonus item.
  final void Function(BonusType bonusType)? onEaten;

  // ── Asset path constants ──────────────────────────────────────────────────

  /// Directory under which bonus-item sprites are stored.
  static const String bonusAssetsPath = "assets/game/bonuses/";

  /// File extension shared by all bonus sprites.
  static const String bonusesAssetsEndFile = ".png";

  // ── Public API ────────────────────────────────────────────────────────────

  /// Shows the bonus item with a freshly randomised [BonusType].
  ///
  /// If the item is already visible, only its type is re-randomised.
  void setVisible() {
    currentType = BonusType.values[_random.nextInt(BonusType.values.length)];
    isVisible = true;
  }

  /// Advances bonus logic by [dt] seconds.
  ///
  /// Calls [onEaten] and hides the item when Pac-Man is within 0.5 tiles.
  void update(double dt) {
    if (isVisible && dist(_getPacman().x - x, _getPacman().y - y) <= 0.5) {
      onEaten?.call(currentType);
      isVisible = false;
    }
  }

  /// Returns a [Positioned] widget showing the current bonus sprite, or an
  /// empty [Container] when the item is hidden.
  Widget getSprite(double tileSize) => Positioned(
    left: x * tileSize,
    top: y * tileSize,
    child: isVisible
        ? Image.asset(
            "$bonusAssetsPath${currentType.name}$bonusesAssetsEndFile",
          )
        : Container(),
  );

  // ── Private helpers ───────────────────────────────────────────────────────

  final Random _random = Random();

  Pacman _getPacman() => gameManager.pacman;
}