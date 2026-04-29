import 'dart:collection';
import 'dart:math';
import 'package:pacman_application/game/animation/animated_character.dart';
import 'package:pacman_application/game/animation/sprite_animation.dart';
import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/game_map.dart';
import 'package:pacman_application/util.dart';

abstract class Ghost extends AnimatedCharacter {
  GhostState state = GhostState.scatter;
  abstract (int x, int y) scatterLocation;
  bool hasStartedFrightenedMode = false;
  Random random = Random();
  double speed = 8;
  abstract (int x, int y) startingPosition;

  late SpriteAnimation up;
  late SpriteAnimation right;
  late SpriteAnimation down;
  late SpriteAnimation left;
  late SpriteAnimation eatenUp;
  late SpriteAnimation eatenRight;
  late SpriteAnimation eatenDown;
  late SpriteAnimation eatenLeft;
  late SpriteAnimation frightened0;
  late SpriteAnimation frightened1;

  late SpriteAnimation idle;

  @override
  List<SpriteAnimation> get animations => [
    up,
    right,
    down,
    left,
    eatenUp,
    eatenRight,
    eatenDown,
    eatenLeft,
    frightened0,
    frightened1,
  ];

  Ghost({required super.gameManager, this.onDeath, this.onEaten}) {
    up = SpriteAnimation(
      characterName: name,
      animationName: "up",
      spritesAmount: 2,
      isLoop: true,
    );
    right = SpriteAnimation(
      characterName: name,
      animationName: "right",
      spritesAmount: 2,
      isLoop: true,
    );
    down = SpriteAnimation(
      characterName: name,
      animationName: "down",
      spritesAmount: 2,
      isLoop: true,
    );
    left = SpriteAnimation(
      characterName: name,
      animationName: "left",
      spritesAmount: 2,
      isLoop: true,
    );
    eatenUp = SpriteAnimation(
      characterName: name,
      animationName: "eatenUp",
      spritesAmount: 1,
      isLoop: true,
    );
    eatenRight = SpriteAnimation(
      characterName: name,
      animationName: "eatenRight",
      spritesAmount: 1,
      isLoop: true,
    );
    eatenDown = SpriteAnimation(
      characterName: name,
      animationName: "eatenDown",
      spritesAmount: 1,
      isLoop: true,
    );
    eatenLeft = SpriteAnimation(
      characterName: name,
      animationName: "eatenLeft",
      spritesAmount: 1,
      isLoop: true,
    );
    frightened0 = SpriteAnimation(
      characterName: name,
      animationName: "frightened0",
      spritesAmount: 4,
      isLoop: true,
    );
    frightened1 = SpriteAnimation(
      characterName: name,
      animationName: "frightened1",
      spritesAmount: 4,
      isLoop: true,
    );

    currentAnimation = idle;
  }

  final void Function()? onDeath;
  final void Function()? onEaten;

  void updateState() {
    if (state == GhostState.eaten &&
        getGameMap().map[y.round().clamp(0, getGameMap().map.length)][x
                .round()
                .clamp(0, getGameMap().map.first.length)] ==
            GameMap.kGhostHouseInterior) {
      state = GhostState.chase;
    }

    if (dist(getPacman().x - x, getPacman().y - y) <= 0.75) {
      if (state == GhostState.frightened0 || state == GhostState.frightened1) {
        state = GhostState.eaten;
        onEaten?.call();
      } else if (state == GhostState.chase || state == GhostState.scatter) {
        onDeath?.call();
      }
    }
  }

  @override
  void reset() {
    x = startingPosition.$1.toDouble();
    y = startingPosition.$2.toDouble();
    state = GhostState.scatter;
  }

  void chase(
    double dt,
    double pacmanX,
    double pacmanY,
    Direction pacmanDirection,
  );

  void scatter(double dt) {
    hasStartedFrightenedMode = false;

    var direction = ghostChase(
      scatterLocation.$1,
      scatterLocation.$2,
      x.round(),
      y.round(),
      getGameMap(),
    );
    if (direction != null) {
      nextDirection = direction;
    }

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
      nextDirection = Direction.values[random.nextInt(4)];
      if (getGameMap().isWall(x.round(), y.round(), nextDirection)) {
        frightened(dt);
        return;
      } else {
        currentDirection = nextDirection;
        x = x.roundToDouble();
        y = y.roundToDouble();
      }
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

  void eaten(double dt) {
    hasStartedFrightenedMode = false;

    var direction = ghostChase(
      getGameMap().ghostHouseX,
      getGameMap().ghostHouseY,
      x.round(),
      y.round(),
      getGameMap(),
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
  void move(double dt) {
    var pacmanX = getPacman().x;
    var pacmanY = getPacman().y;
    var pacmanDirection = getPacman().currentDirection;

    switch (state) {
      case GhostState.chase:
        chase(dt, pacmanX, pacmanY, pacmanDirection);
        break;
      case GhostState.scatter:
        scatter(dt);
        break;
      case GhostState.frightened0 || GhostState.frightened1:
        frightened(dt);
        break;
      case GhostState.eaten:
        eaten(dt);
        break;
      case GhostState.idle:
        break;
    }
  }

  @override
  void updateAnimation(double dt) {
    currentAnimation = switch (state) {
      GhostState.chase || GhostState.scatter => switch (currentDirection) {
        Direction.up => up,
        Direction.down => down,
        Direction.left => left,
        Direction.right => right,
      },

      GhostState.frightened0 => frightened0,
      GhostState.frightened1 => frightened1,

      GhostState.eaten => switch (currentDirection) {
        Direction.up => eatenUp,
        Direction.down => eatenDown,
        Direction.left => eatenLeft,
        Direction.right => eatenRight,
      },

      GhostState.idle => idle,
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
  void update(double dt) {
    move(dt);
    updateState();
    updateAnimation(dt);
  }
}

Direction? ghostChase(int tx, int ty, int cx, int cy, GameMap gameMap) {
  // return simpleChase(tx, ty, cx, cy, gameMap);
  return complexChase(tx, ty, cx, cy, gameMap);
  // return (sqrt((tx - cx) * (tx - cx) + (ty - cy) * (ty - cy)) <= 10)
  //     ? simpleChase(tx, ty, cx, cy, gameMap)
  //     : complexChase(tx, ty, cx, cy, gameMap);
}

Direction? simpleChase(int tx, int ty, int cx, int cy, GameMap gameMap) {
  if (tx == cx && ty == cy) return null;

  double minDistance = double.infinity;
  Direction? minDisDir;

  for (var dir in Direction.values) {
    double dis = dist(
      tx - (cx + dir.toDelta().$1),
      ty - (cy + dir.toDelta().$2),
    );
    if (!gameMap.isWall(cx, cy, dir) && minDistance > dis) {
      minDistance = dis;
      minDisDir = dir;
    }
  }

  return minDisDir;
}

Direction? complexChase(int tx, int ty, int cx, int cy, GameMap gameMap) {
  if (tx == cx && ty == cy) return null;

  final queue = Queue<(int, int)>();
  final firstDir = <int, Direction>{};

  int key(int x, int y) => y * gameMap.kCols + x;

  for (var dir in Direction.values) {
    final nx = (cx + dir.toDelta().$1 + gameMap.kCols) % gameMap.kCols;
    final ny = (cy + dir.toDelta().$2 + gameMap.kRows) % gameMap.kRows;
    if (nx < 0 || ny < 0 || nx >= gameMap.kCols || ny >= gameMap.kRows) {
      continue;
    }
    final nk = key(nx, ny);
    if (firstDir.containsKey((nk))) {
      continue;
    }
    if (gameMap.isWall(cx, cy, dir)) {
      continue;
    }
    firstDir[nk] = dir;
    queue.add((nx, ny));
  }

  firstDir[key(cx, cy)] = Direction.up; // dummy

  while (queue.isNotEmpty) {
    final (x, y) = queue.removeFirst();

    if (x == tx && y == ty) {
      return firstDir[key(x, y)];
    }

    for (var dir in Direction.values) {
      final nx = (x + dir.toDelta().$1 + gameMap.kCols) % gameMap.kCols;
      final ny = (y + dir.toDelta().$2 + gameMap.kRows) % gameMap.kRows;
      if (nx < 0 || ny < 0 || nx >= gameMap.kCols || ny >= gameMap.kRows) {
        continue;
      }
      final nk = key(nx, ny);
      if (firstDir.containsKey(nk)) {
        continue;
      }
      if (gameMap.isWall(x, y, dir)) {
        continue;
      }
      firstDir[nk] = firstDir[key(x, y)]!;
      queue.add((nx, ny));
    }
  }

  return null;
}

enum GhostState { chase, scatter, frightened0, frightened1, eaten, idle }
