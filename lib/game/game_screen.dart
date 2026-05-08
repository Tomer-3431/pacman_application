import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pacman_application/game/bonus.dart';
import 'package:pacman_application/utils/bonus_type.dart';
import 'package:pacman_application/game/controller/controller.dart';
import 'package:pacman_application/game/controller/end_game_buttons.dart';
import 'package:pacman_application/game/map/game_map.dart';
import 'package:pacman_application/game/ghosts/ghost.dart';
import 'package:pacman_application/game/pacman.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The main in-game screen widget.
///
/// Renders the maze image, all dots, power pellets, ghosts, Pac-Man, the
/// HUD (score / high score / lives), the bonus item, the collected-bonuses
/// strip, and either the D-pad [Controller] or the [EndGameButtons].
///
/// A [Timer] drives `setState` at the same rate as the game's [dt] so the
/// widget rebuilds every tick.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.gameMessage,
    required this.controller,
    required this.gameMap,
    required this.pacman,
    required this.getScore,
    required this.getLives,
    required this.getHighScore,
    required this.ghosts,
    required this.bonus,
    required this.dt,
    required this.bonusesTaken,
    required this.endGameButtons,
    required this.isGameOver,
  });

  // ── Game objects ──────────────────────────────────────────────────────────

  /// The shared game map (tiles, dots, super-dots).
  final GameMap gameMap;

  /// The player-controlled Pac-Man character.
  final Pacman pacman;

  /// All four ghost instances.
  final List<Ghost> ghosts;

  /// The bonus item that appears periodically.
  final Bonus bonus;

  /// Bonuses collected so far — shown as icons at the bottom of the screen.
  final List<BonusType> bonusesTaken;

  // ── UI components ─────────────────────────────────────────────────────────

  /// In-game overlay text (e.g. "READY!", "GAME OVER").
  final Widget Function(double tileSize) gameMessage;

  /// The D-pad controller shown during normal play.
  final Controller controller;

  /// Retry / Exit buttons shown when [isGameOver] returns `true`.
  final EndGameButtons endGameButtons;

  // ── Callbacks ─────────────────────────────────────────────────────────────

  /// Returns the current score.
  final int Function() getScore;

  /// Returns the current number of lives.
  final int Function() getLives;

  /// Returns the current high score.
  final int Function() getHighScore;

  /// Returns whether the game is in a game-over state.
  final bool Function() isGameOver;

  // ── Timing ────────────────────────────────────────────────────────────────

  /// Game tick delta-time in seconds; used to set the rebuild timer rate.
  final double dt;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // ── State ─────────────────────────────────────────────────────────────────

  Timer? _uiTimer;

  /// Custom colour overrides loaded from [SharedPreferences].
  Color? _pacmanColor;
  Color? _blinkyColor;
  Color? _pinkyColor;
  Color? _inkyColor;
  Color? _clydeColor;
  Color? _mapColor;

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadCustomColors();

    // Rebuild the widget at the same cadence as the game loop.
    _uiTimer = Timer.periodic(
      Duration(milliseconds: (widget.dt * 1000).round()),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  // ── Widget ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Calculate the largest tile size that fits both dimensions.
    double tileSize = screenSize.width / widget.gameMap.kCols;
    if (tileSize * widget.gameMap.kRows > screenSize.height) {
      tileSize = screenSize.height / widget.gameMap.kRows;
    }
    final mazeWidth = tileSize * widget.gameMap.kCols;
    final mazeHeight = tileSize * widget.gameMap.kRows;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 20,
          children: [
            _buildHud(),

            // ── Maze ──────────────────────────────────────────────────────
            Stack(
              children: [
                Center(
                  child: Image.asset(
                    widget.gameMap.mapAssetPath,
                    width: mazeWidth,
                    height: mazeHeight,
                    fit: BoxFit.fill,
                    color: _mapColor,
                  ),
                ),
                widget.gameMessage(tileSize),
                ...widget.gameMap.dots.map((dot) => dot.showOnStack(tileSize)),
                ...widget.gameMap.superDots.map(
                  (superDot) => superDot.showOnStack(tileSize),
                ),
                ...widget.ghosts.map(
                  (ghost) => ghost.getSprite(
                    tileSize,
                    color: _getGhostColor(ghost.name),
                  ),
                ),
                widget.pacman.getSprite(tileSize, color: _pacmanColor),
                widget.pacman.nextDirectionArrow(tileSize, color: _pacmanColor),
                widget.bonus.getSprite(tileSize),
              ],
            ),

            _buildBonusStrip(widget.bonusesTaken),

            widget.isGameOver()
                ? widget.endGameButtons
                : widget.controller,
          ],
        ),
      ),
    );
  }

  // ── HUD ───────────────────────────────────────────────────────────────────

  /// Builds the top bar showing score, high score, and remaining lives.
  Widget _buildHud() {
    return Container(
      height: 50,
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        spacing: 40,
        children: [
          _buildScoreColumn("SCORE", widget.getScore()),
          _buildScoreColumn("HIGH SCORE", widget.getHighScore()),
          _buildLivesIndicator(widget.getLives() - 1),
        ],
      ),
    );
  }

  /// A two-line label + number column for the score display.
  Widget _buildScoreColumn(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: "PressStart",
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        Text(
          value.toString(),
          style: const TextStyle(
            fontFamily: "PressStart",
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  /// Renders up to 9 small Pac-Man icons representing remaining lives.
  ///
  /// Icons are arranged in rows of 3, with a maximum of 3 rows.
  Widget _buildLivesIndicator(int lives) {
    if (lives <= 0) return const SizedBox(width: 50);

    final image = Image.asset("assets/game/pacman.png");
    return Column(
      spacing: 1,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: List.generate(
        min((lives / 3).ceil(), 3),
        (row) => Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            min(lives - row * 3, 3),
            (_) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: image,
            ),
          ),
        ),
      ),
    );
  }

  // ── Bonus strip ───────────────────────────────────────────────────────────

  /// Renders up to 8 collected-bonus icons in a right-aligned row.
  Widget _buildBonusStrip(List<BonusType> bonuses) => Padding(
    padding: const EdgeInsets.all(2.0),
    child: bonuses.isNotEmpty
        ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: bonuses
                .sublist(0, min(8, bonuses.length))
                .map(
                  (bonusType) => Image.asset(
                    "${Bonus.bonusAssetsPath}${bonusType.name}${Bonus.bonusesAssetsEndFile}",
                  ),
                )
                .toList(),
          )
        : const SizedBox(height: 5),
  );

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Loads custom character/map colour overrides from [SharedPreferences].
  Future<void> _loadCustomColors() async {
    final prefs = await SharedPreferences.getInstance();

    Color? readColor(String key) {
      final a = prefs.getInt("$key/a");
      final r = prefs.getInt("$key/r");
      final g = prefs.getInt("$key/g");
      final b = prefs.getInt("$key/b");
      if (a == null || r == null || g == null || b == null) return null;
      return Color.fromARGB(a, r, g, b);
    }

    final pacman = readColor("pacmanColor");
    final blinky = readColor("blinkyColor");
    final pinky  = readColor("pinkyColor");
    final inky   = readColor("inkyColor");
    final clyde  = readColor("clydeColor");
    final map    = readColor("mapColor");

    // Only call setState if at least one colour was loaded.
    if ([pacman, blinky, pinky, inky, clyde, map].any((c) => c != null)) {
      setState(() {
        _pacmanColor = pacman ?? _pacmanColor;
        _blinkyColor = blinky ?? _blinkyColor;
        _pinkyColor  = pinky  ?? _pinkyColor;
        _inkyColor   = inky   ?? _inkyColor;
        _clydeColor  = clyde  ?? _clydeColor;
        _mapColor    = map    ?? _mapColor;
      });
    }
  }

  /// Returns the custom tint colour for the ghost with [name], or `null`.
  Color? _getGhostColor(String name) {
    return switch (name) {
      "Blinky" => _blinkyColor,
      "Pinky"  => _pinkyColor,
      "Inky"   => _inkyColor,
      "Clyde"  => _clydeColor,
      _        => null,
    };
  }
}