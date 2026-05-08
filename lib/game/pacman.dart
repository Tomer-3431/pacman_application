import 'package:flutter/material.dart';
import 'package:pacman_application/utils/constants.dart';
import 'package:pacman_application/game/animation/animated_character.dart';
import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/map/game_map.dart';
import 'package:pacman_application/game/animation/sprite_animation.dart';

/// Pac-Man: the player-controlled character.
///
/// [move] applies directional input with wall-collision checks and tunnel
/// wrapping.  [updateAnimation] selects the correct directional cycle.
/// Call [playDeath] when a life is lost to switch to the death animation, then
/// drive it manually with [updateDeathAnimation].
class Pacman extends AnimatedCharacter {
  /// Creates [Pacman] and loads all sprite animations.
  Pacman({required super.gameManager}) {
    x = getGameMap().startingX;
    y = getGameMap().startingY;

    _deathAnimation = SpriteAnimation(
      characterName: _kName,
      animationName: "death",
      spritesAmount: 12,
      isLoop: false,
    );
    _idleAnimation = SpriteAnimation(
      characterName: _kName,
      animationName: "idle",
      spritesAmount: 1,
      isLoop: true,
    );
    _upAnimation = SpriteAnimation(
      characterName: _kName,
      animationName: "up",
      spritesAmount: 3,
      isLoop: true,
    );
    _rightAnimation = SpriteAnimation(
      characterName: _kName,
      animationName: "right",
      spritesAmount: 3,
      isLoop: true,
    );
    _downAnimation = SpriteAnimation(
      characterName: _kName,
      animationName: "down",
      spritesAmount: 3,
      isLoop: true,
    );
    _leftAnimation = SpriteAnimation(
      characterName: _kName,
      animationName: "left",
      spritesAmount: 3,
      isLoop: true,
    );

    currentAnimation = _deathAnimation;
  }

  // ── Constants ─────────────────────────────────────────────────────────────

  static const String _kName = "pacman";

  /// Movement speed in tiles per second.
  static const double _kSpeed = 15;

  // ── AnimatedCharacter overrides (identity) ────────────────────────────────

  @override
  final String name = _kName;

  // ── AnimatedCharacter overrides (mutable state) ───────────────────────────

  @override
  Direction currentDirection = Direction.left;

  @override
  Direction nextDirection = Direction.left;

  @override
  double x = 0;

  @override
  double y = 0;

  // ── Animations ────────────────────────────────────────────────────────────

  late SpriteAnimation _deathAnimation;
  late SpriteAnimation _idleAnimation;
  late SpriteAnimation _upAnimation;
  late SpriteAnimation _rightAnimation;
  late SpriteAnimation _downAnimation;
  late SpriteAnimation _leftAnimation;

  @override
  List<SpriteAnimation> get animations => [
    _deathAnimation,
    _idleAnimation,
    _upAnimation,
    _rightAnimation,
    _downAnimation,
    _leftAnimation,
  ];

  // ── Public API ────────────────────────────────────────────────────────────

  /// Switches to the death animation.  Drive it with [updateDeathAnimation].
  void playDeath() {
    currentAnimation = _deathAnimation;
  }

  /// Advances only the death animation by [dt] seconds.
  ///
  /// Called by [GameManager] while the game is paused after a death.
  void updateDeathAnimation(double dt) {
    currentAnimation.update(dt);
  }

  /// Returns a [Positioned] arrow icon indicating [nextDirection].
  ///
  /// Helps the player see their queued turn. Pass [color] to match the
  /// custom Pac-Man colour setting.
  Widget nextDirectionArrow(double tileSize, {Color? color}) {
    return Positioned(
      left: (x + nextDirection.toDelta().$1) * tileSize,
      top: (y + nextDirection.toDelta().$2) * tileSize,
      child: Transform.rotate(
        angle: nextDirection.toAngle(),
        child: Icon(
          Icons.arrow_drop_up_sharp,
          color: color ?? pacmanColor,
          size: tileSize,
        ),
      ),
    );
  }

  // ── AnimatedCharacter overrides (behaviour) ───────────────────────────────

  @override
  void move(double dt) {
    // Apply a queued direction change if the next tile is passable.
    if (currentDirection != nextDirection &&
        !getGameMap().isWall(x.round(), y.round(), nextDirection, isPacman: true)) {
      x = x.roundToDouble();
      y = y.roundToDouble();
      currentDirection = nextDirection;
    }

    // Stop at walls.
    if (getGameMap().isWall(x.round(), y.round(), currentDirection, isPacman: true)) {
      x = x.roundToDouble();
      y = y.roundToDouble();
      return;
    }

    // Advance position.
    switch (currentDirection) {
      case Direction.up:
        y -= _kSpeed * dt;
        break;
      case Direction.down:
        y += _kSpeed * dt;
        break;
      case Direction.left:
        x -= _kSpeed * dt;
        break;
      case Direction.right:
        x += _kSpeed * dt;
        break;
    }

    x = x.clamp(0, getGameMap().kCols - 1).toDouble();
    y = y.clamp(0, getGameMap().kRows - 1).toDouble();

    // Handle tunnel wrap-around.
    if (getGameMap().map[y.round()][x.round()] == GameMap.kTunnel) {
      if (x < 1) {
        x = getGameMap().kCols - 2.01;
      } else if (x > getGameMap().kCols - 2) {
        x = 1.01;
      }
    }
  }

  @override
  void updateAnimation(double dt) {
    currentAnimation = switch (currentDirection) {
      Direction.up => _upAnimation,
      Direction.down => _downAnimation,
      Direction.left => _leftAnimation,
      Direction.right => _rightAnimation,
    };

    for (final animation in animations) {
      if (animation != currentAnimation) {
        animation.idle();
      } else {
        animation.update(dt);
      }
    }
  }

  @override
  void reset() {
    x = getGameMap().startingX;
    y = getGameMap().startingY;
    currentDirection = Direction.left;
    nextDirection = Direction.left;
  }
}