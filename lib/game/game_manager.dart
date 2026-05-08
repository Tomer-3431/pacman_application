import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:pacman_application/utils/constants.dart';
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

// ── Audio state ────────────────────────────────────────────────────────────

/// Describes which audio loop the game should currently be playing.
enum _AudioState { idle, normal, blue, eye }

/// Central controller for the Pac-Man game.
///
/// [GameManager] owns all game objects ([gameMap], [pacman], [ghosts],
/// [bonus]) and drives the main game loop via a [Timer.periodic].  It handles:
/// - Score / lives / high score tracking.
/// - Ghost state transitions (chase ↔ scatter toggle every 5 s).
/// - Frightened-mode timers after a super-dot is eaten.
/// - Bonus item scheduling.
/// - Death / game-over flow.
/// - Audio state machine.
///
/// Pass `start: true` to [GameManager] to begin the game immediately, or call
/// [initGame] manually once the widget tree is ready.
class GameManager {
  /// Creates a [GameManager], optionally starting the game loop immediately.
  ///
  /// All callback parameters are optional; pass them to wire up your UI.
  GameManager({
    bool start = false,
    int Function()? highScore,
    void Function(int score)? onGameOver,
    void Function()? onRetry,
    void Function()? onExit,
    void Function(BonusType bonus)? onGettingBonus,
  }) {
    this.onGameOver      = onGameOver      ?? (_) {};
    this.onRetry         = onRetry         ?? () {};
    this.onExit          = onExit          ?? () {};
    this.onGettingBonus  = onGettingBonus  ?? (_) {};

    if (highScore != null) {
      this.highScore = highScore();
      _getHighScoreCallback = highScore;
    }

    if (start) initGame();
  }

  // ── Scoring & progression ─────────────────────────────────────────────────

  /// Current score for this session.
  int score = 0;

  /// All-time high score; updated live if [score] exceeds it.
  int highScore = 0;

  /// Index of the current maze screen (increments when all dots are cleared).
  int screenNum = 0;

  /// Points awarded for the next ghost eaten in the current frightened chain.
  ///
  /// Starts at 10 and doubles with each consecutive ghost eaten.
  int nextGhostEatenScore = 10;

  /// Remaining lives.  Game over when this reaches 0.
  int lives = 3;

  // ── Flags ─────────────────────────────────────────────────────────────────

  /// Whether the game is currently paused (death animation, level transition).
  bool isPaused = false;

  /// Whether the game has ended.
  bool isGameOver = false;

  /// Prevents triggering the next-screen transition more than once per clear.
  bool _hasTriggeredNextScreen = false;

  // ── Game objects ──────────────────────────────────────────────────────────

  /// The game map (tiles, dots, super-dots, layout constants).
  late final GameMap gameMap = GameMap(
    map: defaultMap,
    onDotEaten: _onDotEaten,
    onSuperDotEaten: _onSuperDotEaten,
  );

  /// The player-controlled Pac-Man character.
  late final Pacman pacman = Pacman(gameManager: this);

  /// All four ghosts in order: Blinky, Pinky, Inky, Clyde.
  late final List<Ghost> ghosts = [
    Blinky(gameManager: this, onDeath: _onDeath, onEaten: _onGhostEaten),
    Pinky (gameManager: this, onDeath: _onDeath, onEaten: _onGhostEaten),
    Inky  (gameManager: this, onDeath: _onDeath, onEaten: _onGhostEaten),
    Clyde (gameManager: this, onDeath: _onDeath, onEaten: _onGhostEaten),
  ];

  /// The bonus item that periodically appears in the centre of the maze.
  late final Bonus bonus = Bonus(gameManager: this, onEaten: _onBonusEaten);

  /// Bonuses collected this session (shown as icons on screen).
  late final List<BonusType> bonusesTaken = [];

  // ── Timers ────────────────────────────────────────────────────────────────

  /// Game-loop delta-time in seconds.
  final double dt = 0.001;

  /// All active [GameTimer] instances updated each tick.
  late final List<GameTimer> _gameTimers = [_bonusTimer];

  /// Periodically makes the bonus item visible (every 10 s, looping).
  late final GameTimer _bonusTimer = GameTimer(
    10,
    onEnd: () => bonus.setVisible(),
    isLoop: true,
  );

  /// Main [Timer.periodic] that drives the game loop.
  late Timer _periodicTimer;

  /// High-precision stopwatch used to calculate real-elapsed delta-time.
  late final Stopwatch _stopwatch = Stopwatch();

  /// Timestamp of the last tick in seconds (used to compute real dt).
  double _lastTickTime = 0;

  // ── UI components ─────────────────────────────────────────────────────────

  /// The on-screen D-pad; wired to update [pacman.nextDirection].
  late final Controller controller = Controller(
    onDirectionChanged: (direction) => pacman.nextDirection = direction,
  );

  /// Retry / Exit buttons shown after game over.
  late final EndGameButtons endGameButtons = EndGameButtons(
    size: 120,
    onRetry: onRetry,
    onExit: onExit,
  );

  /// The main game screen widget.
  late final GameScreen currentScreen = GameScreen(
    gameMessage:    (x) => _gameMessage(x),
    gameMap:        gameMap,
    controller:     controller,
    pacman:         pacman,
    ghosts:         ghosts,
    getScore:       () => score,
    getLives:       () => lives,
    dt:             dt,
    bonus:          bonus,
    bonusesTaken:   bonusesTaken,
    getHighScore:   () => highScore,
    isGameOver:     () => isGameOver,
    endGameButtons: endGameButtons,
  );

  // ── In-game message overlay ───────────────────────────────────────────────

  /// Builder for the overlay text (e.g. "READY!", "GAME OVER", empty widget).
  Widget Function(double tileSize) _gameMessage = (double tileSize) =>
      Positioned(
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

  // ── External callbacks ────────────────────────────────────────────────────

  /// Called with the final score when the game ends.
  late final void Function(int score) onGameOver;

  /// Called when the player chooses to retry.
  late final void Function() onRetry;

  /// Called when the player chooses to exit.
  late final void Function() onExit;

  /// Called each time Pac-Man collects a bonus item.
  late final void Function(BonusType) onGettingBonus;

  /// Optional callback that returns the persisted high score from the UI layer.
  int Function()? _getHighScoreCallback;

  // ── Audio ─────────────────────────────────────────────────────────────────

  final AudioPlayer _audioPlayer = AudioPlayer();

  _AudioState _currentAudioState = _AudioState.idle;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Starts the game: plays the start jingle, then begins the game loop after
  /// a 5-second countdown (matching the "READY!" display duration).
  void initGame() {
    _audioPlayer.play(AssetSource("audio/Start_Music.mp3"));
    highScore = _getHighScoreCallback?.call() ?? highScore;

    Timer(const Duration(seconds: 5), () {
      _gameMessage = (x) => Container();
      _bonusTimer.start();
      _stopwatch.start();

      _periodicTimer = Timer.periodic(
        Duration(milliseconds: (dt * 1000).toInt()),
        (timer) {
          final realDt =
              (_stopwatch.elapsedMicroseconds / 1_000_000.0) - _lastTickTime;
          _lastTickTime = _stopwatch.elapsedMicroseconds / 1_000_000.0;

          if (isPaused) {
            pacman.updateDeathAnimation(realDt);
          } else {
            for (final timer in _gameTimers) {
              timer.update(realDt);
            }
            _update(realDt);
          }
        },
      );
    });

    // Toggle ghosts between chase and scatter every 5 seconds.
    Timer.periodic(const Duration(seconds: 5), (_) {
      for (final ghost in ghosts) {
        if (ghost.state == GhostState.chase) {
          ghost.state = GhostState.scatter;
        } else if (ghost.state == GhostState.scatter) {
          ghost.state = GhostState.chase;
        }
      }
    });
  }

  // ── Private game-loop ─────────────────────────────────────────────────────

  /// Called every tick while the game is not paused.
  void _update(double dt) {
    pacman.update(dt);

    for (final dot in gameMap.dots) {
      dot.checkIfEaten(pacman.x, pacman.y);
    }
    for (final superDot in gameMap.superDots) {
      superDot.checkIfEaten(pacman.x, pacman.y);
    }

    // Keep Inky's static Blinky-position reference up to date.
    Inky.setBlinkyPosition(ghosts[0].x, ghosts[0].y);

    bonus.update(dt);

    if (score > highScore) highScore = score;

    // Update ghosts and determine audio state.
    final previousAudioState = _currentAudioState;
    _currentAudioState = _AudioState.normal;

    for (final ghost in ghosts) {
      ghost.update(dt);

      switch (ghost.state) {
        case GhostState.frightened0 || GhostState.frightened1:
          if (_currentAudioState == _AudioState.normal) {
            _currentAudioState = _AudioState.blue;
          }
        case GhostState.eaten:
          _currentAudioState = _AudioState.eye;
        default:
          break;
      }
    }

    // Switch audio track when state changes.
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    if (_currentAudioState != previousAudioState) {
      switch (_currentAudioState) {
        case _AudioState.idle:
          break;
        case _AudioState.normal:
          _audioPlayer.play(AssetSource("audio/Pacman_Eating_Dots.mp3"));
        case _AudioState.blue:
          _audioPlayer.play(AssetSource("audio/Ghost_Turn_To_Blue.mp3"));
        case _AudioState.eye:
          _audioPlayer.play(AssetSource("audio/Ghost_Return_To_Home.mp3"));
      }
    }

    // Level clear — all dots collected.
    if (!_hasTriggeredNextScreen && gameMap.remainingDots == 0) {
      isPaused = true;
      _hasTriggeredNextScreen = true;

      Timer(const Duration(microseconds: 750), () {
        screenNum++;
        for (final ghost in ghosts) {
          ghost.reset();
        }
        pacman.reset();
        gameMap.reset();

        Timer(const Duration(seconds: 2), () {
          isPaused = false;
          _hasTriggeredNextScreen = false;
        });
      });
    }
  }

  // ── Collectible callbacks ─────────────────────────────────────────────────

  void _onDotEaten() {
    if ((score % 100) >= 99) lives++;
    score += 1;
  }

  void _onSuperDotEaten() {
    if ((score % 100) >= 90) lives++;
    score += 10;

    for (final ghost in ghosts) {
      ghost.state = GhostState.frightened0;
    }

    // After 8 s, switch frightened0 → frightened1 (warning flash).
    _gameTimers.add(
      GameTimer(
        8,
        onEnd: () {
          for (final ghost in ghosts) {
            if (ghost.state == GhostState.frightened0) {
              ghost.state = GhostState.frightened1;
            }
          }
        },
        isOn: true,
      ),
    );

    // After 10 s, end frightened mode entirely.
    _gameTimers.add(
      GameTimer(
        10,
        onEnd: () {
          for (final ghost in ghosts) {
            if (ghost.state == GhostState.frightened1) {
              ghost.state = GhostState.chase;
              nextGhostEatenScore = 10;
            }
          }
        },
        isOn: true,
      ),
    );
  }

  void _onBonusEaten(BonusType type) {
    bonusesTaken.add(type);
    if (score % 100 >= 90) lives++;
    score += 10;
    onGettingBonus(type);
  }

  // ── Death / game-over flow ────────────────────────────────────────────────

  /// Handles Pac-Man's death: plays the death animation, resets characters,
  /// decrements lives, and checks for game over.
  void _onDeath() {
    isPaused = true;

    _audioPlayer.setReleaseMode(ReleaseMode.release);
    _audioPlayer.play(AssetSource("audio/Fail.mp3"));
    _currentAudioState = _AudioState.idle;
    pacman.playDeath();

    Timer(const Duration(seconds: 3), () {
      isPaused = false;
      for (final ghost in ghosts) {
        ghost.reset();
      }
      pacman.reset();
      lives--;

      if (lives <= 0) {
        _triggerGameOver();
      }
    });
  }

  /// Briefly pauses the game and awards score when Pac-Man eats a ghost.
  void _onGhostEaten() {
    isPaused = true;
    if (100 - (score % 100) <= nextGhostEatenScore) lives++;
    score += nextGhostEatenScore;
    nextGhostEatenScore *= 2;
    Timer(const Duration(microseconds: 500), () => isPaused = false);
  }

  /// Stops the game loop, shows "GAME OVER", and fires [onGameOver].
  void _triggerGameOver() {
    isGameOver = true;

    _gameMessage = (double tileSize) => Positioned(
      top: tileSize * 16.3,
      left: tileSize * 9.3,
      child: Center(
        child: const Text(
          "GAME OVER",
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: "PressStart",
          ),
        ),
      ),
    );

    for (final ghost in ghosts) {
      ghost.state = GhostState.idle;
    }

    _periodicTimer.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    onGameOver(score);
  }
}