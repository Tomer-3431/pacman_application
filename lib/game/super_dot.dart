import 'package:flutter/material.dart';

/// A large power pellet that temporarily puts ghosts into frightened mode.
///
/// Functionally identical to [Dot] but larger and worth more points.  When
/// Pac-Man collects a [SuperDot] the [GameManager] switches all ghosts to
/// [GhostState.frightened0].
class SuperDot extends StatelessWidget {
  /// Creates a [SuperDot] at grid position ([x], [y]).
  ///
  /// [onEaten] is called exactly once per round when the pellet is collected.
  SuperDot(this.x, this.y, {super.key, required this.onEaten})
      : _isEaten = false;

  // ── Identity / position ───────────────────────────────────────────────────

  /// Horizontal grid column of this power pellet.
  final int x;

  /// Vertical grid row of this power pellet.
  final int y;

  // ── State ─────────────────────────────────────────────────────────────────

  /// Whether this pellet has already been collected in the current round.
  bool _isEaten;

  // ── Callbacks ─────────────────────────────────────────────────────────────

  /// Invoked once when Pac-Man eats this power pellet.
  final void Function() onEaten;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Checks whether Pac-Man (at [pacmanX], [pacmanY]) is close enough to eat
  /// this pellet.  Tolerance is ±0.5 tiles on both axes.
  void checkIfEaten(double pacmanX, double pacmanY) {
    if (!_isEaten && (pacmanX - x).abs() < 0.5 && (pacmanY - y).abs() < 0.5) {
      _eat();
    }
  }

  /// Restores the pellet so it is visible and collectable again.
  void reset() {
    _isEaten = false;
  }

  /// Returns a [Positioned] widget that renders the pellet inside a [Stack].
  ///
  /// The pellet is centred inside its tile using a 0.5-tile offset.
  /// Renders an empty [Container] when already eaten.
  Widget showOnStack(double tileSize) {
    return Positioned(
      left: (x + 0.5) * tileSize,
      top: (y + 0.5) * tileSize,
      child: _isEaten ? Container() : this,
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Marks the pellet as eaten and fires [onEaten].
  void _eat() {
    onEaten();
    _isEaten = true;
  }

  // ── Widget ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints.tight(const Size(7, 7)),
    decoration: BoxDecoration(
      color: Colors.amber[900],
      shape: BoxShape.circle,
    ),
  );
}