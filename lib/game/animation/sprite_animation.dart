import 'package:flutter/material.dart';

/// Base path under which all character sprite sheets are stored.
const String _kAssetsPath = "assets/game/characters/";

/// File extension shared by all sprite images.
const String _kSpriteFileExtension = ".png";

/// Manages a single named sprite animation for a game character.
///
/// Sprites are loaded from:
///   `assets/game/characters/<characterName>/<animationName>/<characterName>_<animationName>_<index>.png`
///
/// Call [update] every frame to advance the animation, and [idle] to reset it.
class SpriteAnimation {
  /// Creates a [SpriteAnimation] and builds the asset-path list for every frame.
  ///
  /// [characterName]  – folder name of the character (case-insensitive on disk).
  /// [animationName]  – sub-folder / state name (e.g. "left", "death").
  /// [spritesAmount]  – total number of frames in the animation.
  /// [isLoop]         – whether the animation wraps back to frame 0 after finishing.
  /// [frameSpeed]     – seconds each frame is displayed (default ≈ 8 fps).
  SpriteAnimation({
    required this.characterName,
    required this.animationName,
    required this.spritesAmount,
    this.isLoop = false,
    this.frameSpeed = 1 / 8,
  }) {
    for (int i = 0; i < spritesAmount; i++) {
      _paths.add(
        "$_kAssetsPath${characterName.toLowerCase()}/$animationName/${characterName.toLowerCase()}_${animationName}_$i$_kSpriteFileExtension",
      );
    }
  }

  // ── Identity ────────────────────────────────────────────────────────────────

  /// Name of the character this animation belongs to (e.g. "Pacman", "Blinky").
  final String characterName;

  /// Name of the animation state (e.g. "left", "frightened0", "death").
  final String animationName;

  /// Total number of frames in this animation.
  final int spritesAmount;

  /// Seconds each frame is held before advancing. Defaults to 1/8 s (8 fps).
  final double frameSpeed;

  /// Whether the animation loops continuously (`true`) or plays once (`false`).
  final bool isLoop;

  // ── State ───────────────────────────────────────────────────────────────────

  /// Resolved asset paths for every frame, built in the constructor.
  final List<String> _paths = [];

  /// Accumulator used to determine when to advance to the next frame.
  double _clock = 0;

  /// Zero-based index of the frame currently being displayed.
  int _currentIndex = 0;

  /// Whether [update] has been called at least once since the last [idle].
  bool _started = false;

  /// `true` once a non-looping animation has shown its last frame.
  bool isDone = false;

  /// When `true`, [update] has no effect and the current frame is held.
  bool isPaused = false;

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Returns the [Image] widget for the currently active frame.
  ///
  /// Pass [color] to tint the image (useful for ghost colour customisation).
  Image getImage({Color? color}) {
    return Image.asset(_paths[_currentIndex], color: color);
  }

  /// Advances the animation by [dt] seconds.
  ///
  /// Has no effect when [isPaused] is `true` or [isDone] is `true`.
  void update(double dt) {
    if (isPaused) return;

    _clock += dt;

    if (isDone) return;

    if (!_started) {
      _started = true;
    }

    while (_clock >= frameSpeed) {
      if (_currentIndex + 1 == spritesAmount) {
        if (isLoop) {
          _clock -= frameSpeed;
          _currentIndex = 0;
        } else {
          isDone = true;
          return;
        }
      } else {
        _clock -= frameSpeed;
        _currentIndex++;
      }
    }
  }

  /// Resets the animation to its first frame and clears all timing state.
  ///
  /// Called on animations that are not the active one so they are ready to play
  /// from the beginning the next time they are selected.
  void idle() {
    _started = false;
    isDone = false;
    _clock = 0;
    _currentIndex = 0;
  }
}