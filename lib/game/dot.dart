import 'package:flutter/material.dart';

/// A small collectible dot placed on the game map.
///
/// Dots are created by [GameMap] during initialisation.  Each dot knows its
/// grid position and fires [onEaten] the first time Pac-Man passes over it.
/// Call [reset] to restore the dot for a new round.
class Dot extends StatelessWidget {
  /// Creates a [Dot] at grid position ([x], [y]).
  ///
  /// [onEaten] is called exactly once per life/round when the dot is collected.
  Dot(this.x, this.y, {super.key, required this.onEaten}) : _isEaten = false;

  // ── Identity / position ───────────────────────────────────────────────────

  /// Horizontal grid column of this dot.
  final int x;

  /// Vertical grid row of this dot.
  final int y;

  // ── State ─────────────────────────────────────────────────────────────────

  /// Whether this dot has already been collected in the current round.
  bool _isEaten;

  // ── Callbacks ─────────────────────────────────────────────────────────────

  /// Invoked once when Pac-Man eats this dot.
  final void Function() onEaten;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Checks whether Pac-Man (at [pacmanX], [pacmanY]) is close enough to eat
  /// this dot.  Tolerance is ±0.5 tiles on both axes.
  void checkIfEaten(double pacmanX, double pacmanY) {
    if (!_isEaten && (pacmanX - x).abs() < 0.5 && (pacmanY - y).abs() < 0.5) {
      _eat();
    }
  }

  /// Restores the dot so it is visible and collectable again.
  void reset() {
    _isEaten = false;
  }

  /// Returns a [Positioned] widget that renders the dot inside a [Stack].
  ///
  /// The dot is centred inside its tile using a 0.5-tile offset.
  /// Renders an empty [Container] when already eaten.
  Widget showOnStack(double tileSize) {
    return Positioned(
      left: (x + 0.5) * tileSize,
      top: (y + 0.5) * tileSize,
      child: _isEaten ? Container() : this,
    );
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Marks the dot as eaten and fires [onEaten].
  void _eat() {
    onEaten();
    _isEaten = true;
  }

  // ── Widget ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints.tight(const Size.square(5)),
    decoration: BoxDecoration(
      color: Colors.amber[200],
      shape: BoxShape.circle,
    ),
  );
}