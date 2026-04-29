import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pacman_application/game/bonus.dart';
import 'package:pacman_application/game/controller/controller.dart';
import 'package:pacman_application/game/controller/retry_button.dart';
import 'package:pacman_application/game/game_constants.dart';
import 'package:pacman_application/game/game_map.dart';
import 'package:pacman_application/game/game_screen.dart';
import 'package:pacman_application/game/game_timer.dart';
import 'package:pacman_application/game/ghosts/blinky.dart';
import 'package:pacman_application/game/ghosts/clyde.dart';
import 'package:pacman_application/game/ghosts/ghost.dart';
import 'package:pacman_application/game/ghosts/inky.dart';
import 'package:pacman_application/game/ghosts/pinky.dart';
import 'package:pacman_application/game/pacman.dart';

class GameManager {
  int score = 0;
  int highScore = 0;
  int screenNum = 0;
  int currentGhostEatenScore = 0;
  int nextGhostEatenScore = 10;

  late List<GameTimer> gameTimers = [bonusTimer];

  late final GameMap gameMap = GameMap(
    map: defaultMap,
    onDotEaten: () {
      if ((score % 100) >= 99) {
        lives++;
      }
      score += 1;
    },
    onSuperDotEaten: () {
      if ((score % 100) >= 90) lives++;
      score += 10;
      for (var ghosts in ghosts) {
        ghosts.state = GhostState.frightened0;
      }
      gameTimers.add(
        GameTimer(
          8,
          onEnd: () {
            for (var ghost in ghosts) {
              if (ghost.state == GhostState.frightened0) {
                ghost.state = GhostState.frightened1;
              }
            }
          },
          isOn: true,
        ),
      );
      gameTimers.add(
        GameTimer(
          10,
          onEnd: () {
            for (var ghost in ghosts) {
              if (ghost.state == GhostState.frightened1) {
                ghost.state = GhostState.chase;
                currentGhostEatenScore = 0;
                nextGhostEatenScore = 10;
              }
            }
          },
          isOn: true,
        ),
      );
    },
  );

  late final Pacman pacman = Pacman(gameManager: this);

  bool isGameOver = false;

  late final Controller controller = Controller(
    onDirectionChanged: (direction) {
      pacman.nextDirection = direction;
    },
  );

  late GameScreen currentScreen = GameScreen(
    gameMessege: () => gameMessege,
    topText: () {
      return ghosts.first.state.name;
    },
    gameMap: gameMap,
    controller: controller,
    pacman: pacman,
    ghosts: ghosts,
    getScore: () => score,
    getLives: () => lives,
    dt: dt,
    bonus: bonus,
    bonusesTaken: bonusesTaken,
    getHighScore: () => highScore,
    isGameOver: () => isGameOver,
    retryButton: retryButton,
  );

  late RetryButton retryButton = RetryButton(size: 120, onRetry: onRetry, onExit: onExit,);

  bool paused = false;

  void onDeath() {
    paused = true;

    pacman.playDeath();
    Timer(Duration(seconds: 3), () {
      paused = false;
      for (var ghost in ghosts) {
        ghost.reset();
      }
      pacman.reset();
      // gameMap.reset();
      lives--;
      if (lives <= 0) {
        isGameOver = true;

        gameMessege = Text(
          "GAME OVER!",
          style: TextStyle(
            color: Colors.red,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        );
        for (var ghost in ghosts) {
          ghost.state = GhostState.idle;
        }
        periodicTimer.cancel();
        onGameOver.call(score);
      }
    });
  }

  void onEaten() {
    paused = true;
    currentGhostEatenScore += nextGhostEatenScore;
    if ((score % 100) >= currentGhostEatenScore) lives++;
    score += currentGhostEatenScore;
    nextGhostEatenScore *= 2;
    Timer(Duration(microseconds: 500), () => paused = false);
  }

  late final List<Ghost> ghosts = [
    Blinky(gameManager: this, onDeath: onDeath, onEaten: onEaten),
    Pinky(gameManager: this, onDeath: onDeath, onEaten: onEaten),
    Inky(gameManager: this, onDeath: onDeath, onEaten: onEaten),
    Clyde(gameManager: this, onDeath: onDeath, onEaten: onEaten),
  ];

  int lives = 3;
  Widget gameMessege = Text(
    "READY!",
    style: TextStyle(
      color: Colors.yellow,
      fontSize: 30,
      fontWeight: FontWeight.bold,
    ),
  );

  final double dt = 0.001;
  late Timer periodicTimer;
  late Stopwatch stopwatch = Stopwatch();
  double lastTime = 0;

  void onBonus(BonusType type) {
    bonusesTaken.add(type);
    if (score % 100 >= 90) lives++;
    score += 10;
  }

  late List<BonusType> bonusesTaken = [];
  late Bonus bonus = Bonus(gameManager: this, onEaten: onBonus);
  late GameTimer bonusTimer = GameTimer(
    10,
    onEnd: () {
      bonus.setVisiable();
    },
    isLoop: true,
  );

  late void Function(int score) onGameOver;
  late void Function() onRetry;
  int Function()? getHighScoreFromDisplayer;
  late void Function() onExit;

  GameManager({
    bool start = false,
    int Function()? highScore,
    void Function(int score)? onGameOver,
    void Function()? onRetry,
    void Function()? onExit,
  }) {
    if (onGameOver != null) {
      this.onGameOver = onGameOver;
    } else {
      this.onGameOver = (x) {};
    }

    if (highScore != null) {
      this.highScore = highScore();
      getHighScoreFromDisplayer = highScore;
    }

    if (onRetry != null) {
      this.onRetry = onRetry;
    } else {
      this.onRetry = () {};
    }

    if (onExit != null) {
      this.onExit = onExit;
    } else {
      this.onExit = () {};
    }

    if (start) initGame();
  }

  void initGame() {
    highScore = getHighScoreFromDisplayer?.call() ?? highScore;
    Timer(Duration(seconds: 3), () {
      gameMessege = Container();
      bonusTimer.start();
      stopwatch.start();
      periodicTimer = Timer.periodic(
        Duration(milliseconds: (dt * 1000).toInt()),
        (timer) {
          double realDT =
              (stopwatch.elapsedMicroseconds / 1000000.0) - lastTime;
          lastTime = stopwatch.elapsedMicroseconds / 1000000.0;

          if (paused) {
            pacman.updateDeathAnimation(realDT);
          } else {
            for (var gameTimer in gameTimers) {
              gameTimer.update(realDT);
            }
            update(realDT);
          }
        },
      );
    });

    Timer.periodic(Duration(seconds: 5), (timer) {
      for (var ghost in ghosts) {
        if (ghost.state == GhostState.chase) {
          ghost.state = GhostState.scatter;
        } else if (ghost.state == GhostState.scatter) {
          ghost.state = GhostState.chase;
        }
      }
    });
  }

  bool hasUpdatedNextScreen = false;

  void update(double dt) {
    pacman.update(dt);
    for (var dot in gameMap.dots) {
      dot.checkIfEaten(pacman.x, pacman.y);
    }
    for (var superDot in gameMap.superPoints) {
      superDot.checkIfEaten(pacman.x, pacman.y);
    }
    Inky.setBlinkyLocation(ghosts[0].x, ghosts[0].y);
    bonus.update(dt);
    if (score > highScore) {
      highScore = score;
    }

    for (var ghost in ghosts) {
      ghost.update(dt);
    }

    if (!hasUpdatedNextScreen && gameMap.leftDots == 0) {
      paused = true;
      hasUpdatedNextScreen = true;

      Timer(Duration(microseconds: 750), () {
        screenNum++;
        for (var ghost in ghosts) {
          ghost.reset();
        }
        pacman.reset();
        gameMap.reset();
        Timer(Duration(seconds: 2), () {
          paused = false;
          hasUpdatedNextScreen = false;
        });
      });
    }
  }
}
