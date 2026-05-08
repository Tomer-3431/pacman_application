import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pacman_application/game/animation/animated_character.dart';
import 'package:pacman_application/game/animation/sprite_animation.dart';
import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/map/game_map.dart';
import 'package:pacman_application/utils/util.dart';

/// All possible behavioural states a ghost can be in.
enum GhostState {
  /// Pursuing Pac-Man using the ghost's unique targeting strategy.
  chase,

  /// Retreating to the ghost's fixed corner of the maze.
  scatter,

  /// Flashing blue — vulnerable, warning phase about to expire.
  frightened0,

  /// Flashing white — last few seconds of vulnerability.
  frightened1,

  /// Eyes-only mode: returning to the ghost house after being eaten.
  eaten,

  /// Stationary inside the ghost house; not yet released into the maze.
  idle,
}

/// Abstract base for all four ghosts (Blinky, Pinky, Inky, Clyde).
///
/// Provides the shared state machine ([GhostState]), movement modes
/// ([scatter], [frightened], [eaten]), the BFS pathfinder ([ghostChase]),
/// and animation management.
///
/// Subclasses must implement:
/// - [name], [x], [y], [currentDirection], [nextDirection]
/// - [startingPosition] and [scatterLocation]
/// - [idleAnimation]  – animation shown in [GhostState.idle]
/// - [chase]          – the ghost's unique targeting behaviour
abstract class Ghost extends AnimatedCharacter {
  /// Creates a [Ghost] and initialises all animation objects.
  ///
  /// [onDeath]  – called when Pac-Man collides with a non-frightened ghost.
  /// [onEaten]  – called when Pac-Man eats this ghost while frightened.
  Ghost({required super.gameManager, this.onDeath, this.onEaten}) {
    _up = SpriteAnimation(
      characterName: name, animationName: "up",
      spritesAmount: 2, isLoop: true,
    );
    _right = SpriteAnimation(
      characterName: name, animationName: "right",
      spritesAmount: 2, isLoop: true,
    );
    _down = SpriteAnimation(
      characterName: name, animationName: "down",
      spritesAmount: 2, isLoop: true,
    );
    _left = SpriteAnimation(
      characterName: name, animationName: "left",
      spritesAmount: 2, isLoop: true,
    );
    _eatenUp = SpriteAnimation(
      characterName: name, animationName: "eatenUp",
      spritesAmount: 1, isLoop: true,
    );
    _eatenRight = SpriteAnimation(
      characterName: name, animationName: "eatenRight",
      spritesAmount: 1, isLoop: true,
    );
    _eatenDown = SpriteAnimation(
      characterName: name, animationName: "eatenDown",
      spritesAmount: 1, isLoop: true,
    );
    _eatenLeft = SpriteAnimation(
      characterName: name, animationName: "eatenLeft",
      spritesAmount: 1, isLoop: true,
    );
    _frightened0 = SpriteAnimation(
      characterName: name, animationName: "frightened0",
      spritesAmount: 4, isLoop: true,
    );
    _frightened1 = SpriteAnimation(
      characterName: name, animationName: "frightened1",
      spritesAmount: 4, isLoop: true,
    );

    currentAnimation = idleAnimation;
    _currentEyesAnimation = _eatenUp;
  }

  // ── Abstract members (subclass must implement) ────────────────────────────

  /// Grid coordinates the ghost spawns at and returns to on [reset].
  abstract (int x, int y) startingPosition;

  /// Tile this ghost targets while in [GhostState.scatter].
  abstract (int, int) scatterLocation;

  /// Animation played while the ghost is in [GhostState.idle].
  SpriteAnimation get idleAnimation;

  /// Ghost-specific Pac-Man targeting logic, called each tick during [GhostState.chase].
  void chase(double dt, double pacmanX, double pacmanY, Direction pacmanDirection);

  // ── Public state ──────────────────────────────────────────────────────────

  /// Current behavioural state (read and written by [GameManager] and self).
  GhostState state = GhostState.scatter;

  /// Movement speed in tiles per second.
  double speed = 8;

  /// Guards against re-applying the one-time direction reversal on entry to
  /// frightened mode.  Subclasses should reset this to `false` at the start
  /// of their [chase] override.
  bool hasStartedFrightenedMode = false;

  // ── Callbacks ─────────────────────────────────────────────────────────────

  /// Invoked when Pac-Man collides with this non-frightened ghost.
  final void Function()? onDeath;

  /// Invoked when Pac-Man eats this frightened ghost.
  final void Function()? onEaten;

  // ── Directional animation getters (for subclass use in idleAnimation) ─────

  /// Two-frame looping upward-movement animation.
  SpriteAnimation get up => _up;

  /// Two-frame looping rightward-movement animation.
  SpriteAnimation get right => _right;

  /// Two-frame looping downward-movement animation.
  SpriteAnimation get down => _down;

  /// Two-frame looping leftward-movement animation.
  SpriteAnimation get left => _left;

  // ── Private animation storage ─────────────────────────────────────────────

  late SpriteAnimation _up;
  late SpriteAnimation _right;
  late SpriteAnimation _down;
  late SpriteAnimation _left;
  late SpriteAnimation _eatenUp;
  late SpriteAnimation _eatenRight;
  late SpriteAnimation _eatenDown;
  late SpriteAnimation _eatenLeft;
  late SpriteAnimation _frightened0;
  late SpriteAnimation _frightened1;

  /// Directional eyes overlay rendered above the body sprite during chase/scatter.
  SpriteAnimation? _currentEyesAnimation;

  final Random _random = Random();

  @override
  List<SpriteAnimation> get animations => [
    _up, _right, _down, _left,
    _eatenUp, _eatenRight, _eatenDown, _eatenLeft,
    _frightened0, _frightened1,
  ];

  // ── AnimatedCharacter overrides ───────────────────────────────────────────

  @override
  Widget getSprite(double tileSize, {Color? color}) => Positioned(
    top: y * tileSize,
    left: x * tileSize,
    child: Stack(
      children: [
        // Body — tinted only during chase/scatter; other states have
        // built-in sprite colours.
        currentAnimation.getImage(
          color: state == GhostState.chase || state == GhostState.scatter
              ? color
              : null,
        ),
        // Eyes overlay (visible during chase/scatter when a custom colour is set).
        if (color != null && _currentEyesAnimation != null)
          _currentEyesAnimation!.getImage()
        else
          Container(),
      ],
    ),
  );

  @override
  void move(double dt) {
    final pacmanX = getPacman().x;
    final pacmanY = getPacman().y;
    final pacmanDirection = getPacman().currentDirection;

    switch (state) {
      case GhostState.chase:
        chase(dt, pacmanX, pacmanY, pacmanDirection);
      case GhostState.scatter:
        scatter(dt);
      case GhostState.frightened0 || GhostState.frightened1:
        frightened(dt);
      case GhostState.eaten:
        eaten(dt);
      case GhostState.idle:
        break;
    }

    x = x.clamp(0, getGameMap().kCols - 1);
    y = y.clamp(0, getGameMap().kRows - 1);
  }

  @override
  void updateAnimation(double dt) {
    currentAnimation = switch (state) {
      GhostState.chase || GhostState.scatter => switch (currentDirection) {
        Direction.up    => _up,
        Direction.down  => _down,
        Direction.left  => _left,
        Direction.right => _right,
      },
      GhostState.frightened0 => _frightened0,
      GhostState.frightened1 => _frightened1,
      GhostState.eaten => switch (currentDirection) {
        Direction.up    => _eatenUp,
        Direction.down  => _eatenDown,
        Direction.left  => _eatenLeft,
        Direction.right => _eatenRight,
      },
      GhostState.idle => idleAnimation,
    };

    _currentEyesAnimation = switch (state) {
      GhostState.chase || GhostState.scatter => switch (currentDirection) {
        Direction.up    => _eatenUp,
        Direction.down  => _eatenDown,
        Direction.left  => _eatenLeft,
        Direction.right => _eatenRight,
      },
      _ => null,
    };

    for (final animation in animations) {
      if (animation != currentAnimation && animation != _currentEyesAnimation) {
        animation.idle();
      } else {
        animation.update(dt);
      }
    }
  }

  @override
  void update(double dt) {
    move(dt);
    updateState();
    updateAnimation(dt);
  }

  @override
  void reset() {
    x = startingPosition.$1.toDouble();
    y = startingPosition.$2.toDouble();
    state = GhostState.scatter;
  }

  // ── Shared movement modes ─────────────────────────────────────────────────

  /// Moves the ghost toward [scatterLocation] using BFS.
  void scatter(double dt) {
    hasStartedFrightenedMode = false;

    final direction = ghostChase(
      scatterLocation.$1, scatterLocation.$2, x.round(), y.round(),
    );
    if (direction != null) nextDirection = direction;

    if (nextDirection != currentDirection &&
        !getGameMap().isWall(x.round(), y.round(), nextDirection)) {
      x = x.roundToDouble();
      y = y.roundToDouble();
      currentDirection = nextDirection;
    }
    if (getGameMap().isWall(x.round(), y.round(), currentDirection)) {
      x = x.roundToDouble();
      y = y.roundToDouble();
      return;
    }
    stepForward(dt);
  }

  /// Moves the ghost randomly while in frightened mode.
  ///
  /// Reverses direction once on entry, then re-randomises on wall hits.
  void frightened(double dt) {
    if (!hasStartedFrightenedMode) {
      nextDirection = currentDirection.opposite();
      x = x.roundToDouble();
      y = y.roundToDouble();
      if (!getGameMap().isWall(x.round(), y.round(), nextDirection)) {
        currentDirection = nextDirection;
      }
      hasStartedFrightenedMode = true;
      if (getGameMap().isWall(x.round(), y.round(), currentDirection)) {
        return frightened(dt);
      }
    } else if (dt % 1 == 0 ||
        getGameMap().isWall(x.round(), y.round(), currentDirection)) {
      nextDirection = Direction.values[_random.nextInt(4)];
      if (getGameMap().isWall(x.round(), y.round(), nextDirection)) {
        frightened(dt);
        return;
      }
      currentDirection = nextDirection;
      x = x.roundToDouble();
      y = y.roundToDouble();
    }
    stepForward(dt);
  }

  /// Moves the ghost back to the ghost-house entrance (eyes-only).
  void eaten(double dt) {
    hasStartedFrightenedMode = false;

    final direction = ghostChase(
      getGameMap().ghostHouseX, getGameMap().ghostHouseY,
      x.round(), y.round(),
    );
    if (direction != null) nextDirection = direction;

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
    stepForward(dt);
  }

  // ── State transition helper ───────────────────────────────────────────────

  /// Checks proximity to Pac-Man / ghost house and triggers state changes.
  void updateState() {
    // Return to chase after re-entering the ghost house.
    if (state == GhostState.eaten &&
        getGameMap().map[y.round().clamp(0, getGameMap().map.length)][
              x.round().clamp(0, getGameMap().map.first.length)] ==
            GameMap.kGhostHouseInterior) {
      state = GhostState.chase;
    }

    // Collide with Pac-Man.
    if (dist(getPacman().x - x, getPacman().y - y) <= 0.75) {
      if (state == GhostState.frightened0 || state == GhostState.frightened1) {
        state = GhostState.eaten;
        onEaten?.call();
      } else if (state == GhostState.chase || state == GhostState.scatter) {
        onDeath?.call();
      }
    }
  }

  // ── Movement helper ───────────────────────────────────────────────────────

  /// Advances (x, y) by [speed] × [dt] in [currentDirection].
  void stepForward(double dt) {
    switch (currentDirection) {
      case Direction.up:    y -= speed * dt;
      case Direction.down:  y += speed * dt;
      case Direction.left:  x -= speed * dt;
      case Direction.right: x += speed * dt;
    }
  }

  // ── Pathfinding ───────────────────────────────────────────────────────────

  /// Chooses the first [Direction] on the shortest path from (cx, cy) to
  /// (tx, ty) using BFS.  Returns `null` if already at the target.
  Direction? ghostChase(int tx, int ty, int cx, int cy) {
    return complexChase(tx, ty, cx, cy);
  }

  /// Greedy single-step: chooses the adjacent tile closest to (tx, ty).
  ///
  /// Faster than BFS but may get stuck in concave walls.  Available to
  /// subclasses or as a debugging fallback.
  Direction? simpleChase(int tx, int ty, int cx, int cy) {
    if (tx == cx && ty == cy) return null;

    double minDistance = double.infinity;
    Direction? bestDirection;

    for (final dir in Direction.values) {
      final distance = dist(
        tx - (cx + dir.toDelta().$1),
        ty - (cy + dir.toDelta().$2),
      );
      if (!getGameMap().isWall(cx, cy, dir) && minDistance > distance) {
        minDistance = distance;
        bestDirection = dir;
      }
    }
    return bestDirection;
  }

  /// Full BFS from (cx, cy) toward (tx, ty), with map wrap-around support.
  ///
  /// Records the *first* direction taken from the origin for every visited
  /// cell, then returns that direction when the target is reached.
  Direction? complexChase(int tx, int ty, int cx, int cy) {
    if (tx == cx && ty == cy) return null;

    final GameMap gameMap = getGameMap();
    final queue = Queue<(int, int)>();
    final firstDir = <int, Direction>{};

    int key(int x, int y) => y * gameMap.kCols + x;

    // Seed BFS with immediate neighbours of the starting cell.
    for (final dir in Direction.values) {
      final nx = (cx + dir.toDelta().$1 + gameMap.kCols) % gameMap.kCols;
      final ny = (cy + dir.toDelta().$2 + gameMap.kRows) % gameMap.kRows;
      if (nx < 0 || ny < 0 || nx >= gameMap.kCols || ny >= gameMap.kRows) continue;
      final nk = key(nx, ny);
      if (firstDir.containsKey(nk) || gameMap.isWall(cx, cy, dir)) continue;
      firstDir[nk] = dir;
      queue.add((nx, ny));
    }

    firstDir[key(cx, cy)] = Direction.up; // dummy – marks origin as visited

    while (queue.isNotEmpty) {
      final (x, y) = queue.removeFirst();

      if (x == tx && y == ty) return firstDir[key(x, y)];

      for (final dir in Direction.values) {
        final nx = (x + dir.toDelta().$1 + gameMap.kCols) % gameMap.kCols;
        final ny = (y + dir.toDelta().$2 + gameMap.kRows) % gameMap.kRows;
        if (nx < 0 || ny < 0 || nx >= gameMap.kCols || ny >= gameMap.kRows) continue;
        final nk = key(nx, ny);
        if (firstDir.containsKey(nk) || gameMap.isWall(x, y, dir)) continue;
        firstDir[nk] = firstDir[key(x, y)]!;
        queue.add((nx, ny));
      }
    }

    return null;
  }
}