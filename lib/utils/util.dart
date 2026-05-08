import 'dart:math';

/// Utility functions shared across the application.

/// Returns the Euclidean distance from the origin to the point ([x], [y]).
///
/// Equivalent to `sqrt(x² + y²)`. Useful for collision detection and
/// proximity checks inside the game engine.
double dist(num x, num y) {
  return sqrt((x * x + y * y).abs());
}

/// Casts [object] to [T], throwing a [TypeError] if the cast fails.
///
/// Use this when you are certain of the runtime type and want an explicit
/// error on mismatch rather than a silent `null`.
T cast<T extends Object>(dynamic object) => object as T;

/// Attempts to cast [object] to [T], returning `null` instead of throwing
/// if [object] is not an instance of [T].
///
/// Prefer this when reading values from Firebase snapshots whose type is
/// not guaranteed at compile time.
T? tryCast<T extends Object>(dynamic object) => object is T ? object : null;