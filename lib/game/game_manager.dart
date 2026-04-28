import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:pacman_application/game/bonus.dart';
import 'package:pacman_application/game/controller/controller.dart';
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
  int screenNum = 0;
  int currentGhostEatenScore = 0;
  int nextGhostEatenScore = 10;

  bool isSFX = false;

  double volume = 0;

  late List<GameTimer> gameTimers = [bonusTimer];

  late final GameMap gameMap = GameMap(
    map: defaultMap,
    onDotEaten: () {
      if ((score % 100) >= 99) {
        lives++;
        isSFX = true;
        audioPlayer.setReleaseMode(ReleaseMode.stop);
        audioPlayer.play(
          AssetSource("audio/Extended_Sound.mp3"),
          volume: volume,
        );
      }
      score += 1;
      isSFX = true;
      audioPlayer.setReleaseMode(ReleaseMode.stop);
      audioPlayer.play(
        AssetSource("audio/Pacman_Eating_Dots.mp3"),
        volume: volume,
        position: Duration(seconds: 10),
      );
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
  );

  bool paused = false;

  void onDeath() {
    paused = true;

    pacman.playDeath();
    audioPlayer.setReleaseMode(ReleaseMode.release);
    audioPlayer.play(AssetSource("audio/Fail.mp3"), volume: volume);
    Timer(Duration(seconds: 3), () {
      paused = false;
      for (var ghost in ghosts) {
        ghost.reset();
      }
      pacman.reset();
      // gameMap.reset();
      lives--;
      if (lives <= 0) {
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

  AudioPlayer audioPlayer = AudioPlayer();
  BGMusic currentBGMusic = BGMusic.start;

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

  GameManager(BuildContext context) {
    audioPlayer.setReleaseMode(ReleaseMode.release);

    audioPlayer.play(AssetSource("audio/Start_Music.mp3"), volume: volume);
    Timer(Duration(seconds: 3), () {
      gameMessege = Container();
      audioPlayer.setReleaseMode(ReleaseMode.loop);
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

    BGMusic neededMusic = BGMusic.chase;
    for (var ghost in ghosts) {
      ghost.update(dt);
      if (ghost.state == GhostState.eaten) {
        neededMusic = BGMusic.eaten;
      } else if (neededMusic == BGMusic.chase &&
          (ghost.state == GhostState.frightened0 ||
              ghost.state == GhostState.frightened1)) {
        neededMusic = BGMusic.blue;
      }
    }

    if (!isSFX && neededMusic != currentBGMusic) {
      audioPlayer.setReleaseMode(ReleaseMode.loop);

      switch (neededMusic) {
        case BGMusic.chase:
          audioPlayer.play(
            AssetSource("audio/Ghost_Normal_Move.mp3"),
            volume: volume,
          );
          break;

        case BGMusic.blue:
          audioPlayer.play(
            AssetSource("audio/Ghost_Turn_To_Blue.mp3"),
            volume: volume,
          );
          break;

        case BGMusic.eaten:
          audioPlayer.play(
            AssetSource("audio/Ghost_Return_To_Home.mp3"),
            volume: volume,
          );
          break;

        default:
          break;
      }
    }

    currentBGMusic = neededMusic;
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

enum BGMusic { start, chase, blue, eaten, fail }
