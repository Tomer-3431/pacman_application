import 'dart:ui';

/// Represents the different collectible bonus items that can appear on the
/// Pac-Man game board (tile value `4` in [defaultMap]).
///
/// Each variant carries two colours used by [BonusCard] to style the card:
/// - [bgColor]     – background glow / shadow colour.
/// - [borderColor] – card border colour.
///
/// The [name] of each variant (e.g. `"apple"`) is also used as the asset
/// filename and as the Firebase Realtime Database key inside `bonusTable`.
enum BonusType {
  /// Classic red apple. Appears early in the game.
  apple(Color(0xFFB71C1C), Color(0xFFFF0000)),

  /// Golden bell. Mid-game bonus item.
  bell(Color(0xFFDBC000), Color(0xFFFFFF00)),

  /// Red cherry. The first bonus item in the original arcade game.
  cherry(Color(0xFFB71C1C), Color(0xFFFF0000)),

  /// Galaxian flagship. A special high-value bonus.
  galaxian(Color(0xFF0D47A1), Color(0xFF0000FF)),

  /// Blue key. Late-game rare bonus item.
  key(Color(0xFF01579B), Color(0xFF47B7FF)),

  /// Green melon. Mid-game fruit bonus.
  melon(Color(0xFF81C784), Color(0xFF00FF00)),

  /// Orange fruit bonus item.
  orange(Color.fromARGB(255, 46, 16, 0), Color(0xFFFFB751)),

  /// Red strawberry. Appears after the first level completion.
  strawberry(Color(0xFFB71C1C), Color(0xFFFF0000));

  // ── Fields ──────────────────────────────────────────────────────────────

  /// Background glow colour shown behind the bonus image.
  final Color bgColor;

  /// Border colour used on [BonusCard] and the detail dialog.
  final Color borderColor;

  // ── Constructor ─────────────────────────────────────────────────────────

  const BonusType(this.bgColor, this.borderColor);
}