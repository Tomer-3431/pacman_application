import 'package:flutter/material.dart';
import 'package:pacman_application/game/animation/sprite_animation.dart';
import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/game_manager.dart';
import 'package:pacman_application/game/map/game_map.dart';
import 'package:pacman_application/game/game_screen.dart';
import 'package:pacman_application/game/pacman.dart';

/// Base class for every character that moves and animates on the game map.
///
/// Subclasses must implement:
/// - [name]             – unique identifier string.
/// - [x] / [y]         – current tile-space position.
/// - [currentDirection] / [nextDirection] – movement state.
/// - [move]            – positional update logic.
/// - [updateAnimation] – animation selection logic.
/// - [reset]           – restore initial state.
abstract class AnimatedCharacter {
  /// Creates an [AnimatedCharacter] bound to the given [gameManager].
  AnimatedCharacter({required this.gameManager});

  // ── Required identity ─────────────────────────────────────────────────────

  /// Unique display/asset name for this character (e.g. `"Pacman"`, `"Blinky"`).
  abstract final String name;

  // ── Position & direction (mutable) ───────────────────────────────────────

  /// Current horizontal position in tile units.
  abstract double x;

  /// Current vertical position in tile units.
  abstract double y;

  /// The direction this character is currently moving.
  abstract Direction currentDirection;

  /// The direction queued for the next opportunity to turn.
  abstract Direction nextDirection;

  // ── Animation state ───────────────────────────────────────────────────────

  /// All [SpriteAnimation] instances owned by this character.
  late List<SpriteAnimation> animations = [];

  /// The animation that is currently being rendered.
  late SpriteAnimation currentAnimation;

  // ── Dependencies ──────────────────────────────────────────────────────────

  /// Reference to the central [GameManager].
  final GameManager gameManager;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns a [Positioned] widget showing the current animation frame.
  ///
  /// Pass [color] to tint the sprite (used for ghost / Pac-Man customisation).
  Widget getSprite(double tileSize, {Color? color}) => Positioned(
    left: x * tileSize,
    top: y * tileSize,
    child: currentAnimation.getImage(color: color),
  );

  /// Advances movement and animation by [dt] seconds.
  void update(double dt) {
    move(dt);
    updateAnimation(dt);
  }

  /// Restores the character to its initial position and state.
  void reset();

  // ── Abstract callbacks ────────────────────────────────────────────────────

  /// Updates [x] and [y] based on [currentDirection] and game-map collision.
  void move(double dt);

  /// Selects [currentAnimation] based on current state and advances its clock.
  void updateAnimation(double dt);

  // ── Convenience accessors ─────────────────────────────────────────────────

  /// Shortcut to the shared [GameMap].
  GameMap getGameMap() => gameManager.gameMap;

  /// Shortcut to the currently active [GameScreen].
  GameScreen getGameScreen() => gameManager.currentScreen;

  /// Shortcut to the [Pacman] instance managed by [gameManager].
  Pacman getPacman() => gameManager.pacman;
}