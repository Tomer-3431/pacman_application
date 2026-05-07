import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:pacman_application/constants.dart';
import 'package:pacman_application/game/bonus.dart';
import 'package:pacman_application/utils/bonus_type.dart';
import 'package:pacman_application/game/controller/controller.dart';
import 'package:pacman_application/game/controller/end_game_buttons.dart';
import 'package:pacman_application/game/map/game_map.dart';
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
    gameMessege: (x) => gameMessege(x),
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
    endGameButtons: endGameButtons,
  );

  late EndGameButtons endGameButtons = EndGameButtons(
    size: 120,
    onRetry: onRetry,
    onExit: onExit,
  );

  bool paused = false;

  void onDeath() {
    paused = true;

    _audioPlayer.setReleaseMode(ReleaseMode.release);
    _audioPlayer.play(AssetSource("audio/Fail.mp3"));
    _currentAudioState = AudioState.idle;
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

        gameMessege = (double tileSize) => Positioned(
          top: tileSize * 16.3,
          left: tileSize * 9.3,
          child: Center(
            child: Text(
              "GAME OVER",
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: "PressStart"
              ),
            ),
          ),
        );
        for (var ghost in ghosts) {
          ghost.state = GhostState.idle;
        }
        periodicTimer.cancel();
        _audioPlayer.stop();
        _audioPlayer.dispose();
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
  Widget Function(double tileSize) gameMessege = (double tileSize) => Positioned(
    top: 16.2 * tileSize,
    left: 10.5 * tileSize,
    child: Center(
      child: Text(
        "READY!",
        style: TextStyle(
          color: pacmanColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: "PressStart",
        ),
      ),
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
    onGettingBonus(type);
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
  late void Function(BonusType) onGettingBonus;

  final AudioPlayer _audioPlayer = AudioPlayer();

  GameManager({
    bool start = false,
    int Function()? highScore,
    void Function(int score)? onGameOver,
    void Function()? onRetry,
    void Function()? onExit,
    void Function(BonusType bonus)? onGettingBonus,
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

    if (onGettingBonus != null) {
      this.onGettingBonus = onGettingBonus;
    } else {
      this.onGettingBonus = (x) {};
    }

    if (start) initGame();
  }

  void initGame() {
    _audioPlayer.play(AssetSource("audio/Start_Music.mp3"));
    highScore = getHighScoreFromDisplayer?.call() ?? highScore;
    Timer(Duration(seconds: 5), () {
      gameMessege = (x) => Container();
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

    final lastCurrentAudioState = _currentAudioState;
    _currentAudioState = AudioState.normal;
    for (var ghost in ghosts) {
      ghost.update(dt);

      switch (ghost.state) {
        case GhostState.chase || GhostState.scatter:
          break;
        case GhostState.frightened0 || GhostState.frightened1:
          if (_currentAudioState == AudioState.normal) {
            _currentAudioState = AudioState.blue;
          }
          break;
        case GhostState.eaten:
          _currentAudioState = AudioState.eye;
          break;
        case GhostState.idle:
          break;
      }
    }

    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    if (_currentAudioState != lastCurrentAudioState) {
      switch (_currentAudioState) {
        case AudioState.idle:
          // _audioPlayer.stop();
          break;
        case AudioState.normal:
          _audioPlayer.play(AssetSource("audio/Pacman_Eating_Dots.mp3"));
          break;
        case AudioState.blue:
          _audioPlayer.play(AssetSource("audio/Ghost_Turn_To_Blue.mp3"));
          break;
        case AudioState.eye:
          _audioPlayer.play(AssetSource("audio/Ghost_Return_To_Home.mp3"));
          break;
      }
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

  AudioState _currentAudioState = AudioState.idle;
}

enum AudioState { idle, normal, blue, eye }
