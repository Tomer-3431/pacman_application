import 'package:flutter/material.dart';
import 'package:pacman_application/utils/bonus_type.dart';

// ── Game map ───────────────────────────────────────────────────────────────

/// The default 31 × 28 tile layout of the Pac-Man level.
///
/// Cell values:
/// | Value | Meaning              |
/// |-------|----------------------|
/// | 0     | Empty space          |
/// | 1     | Wall                 |
/// | 2     | Small dot            |
/// | 3     | Super dot (power-up) |
/// | 4     | Bonus item spawn     |
/// | 5     | Tunnel               |
/// | 6     | Ghost house door     |
/// | 7     | Ghost house interior |
/// | 8     | Player starting pos  |
const List<List<int>> defaultMap = [
  [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
  [1,2,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,2,1],
  [1,2,1,1,1,1,2,1,1,1,1,1,2,1,1,2,1,1,1,1,1,2,1,1,1,1,2,1],
  [1,3,1,1,1,1,2,1,1,1,1,1,2,1,1,2,1,1,1,1,1,2,1,1,1,1,3,1],
  [1,2,1,1,1,1,2,1,1,1,1,1,2,1,1,2,1,1,1,1,1,2,1,1,1,1,2,1],
  [1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1],
  [1,2,1,1,1,1,2,1,1,2,1,1,1,1,1,1,1,1,2,1,1,2,1,1,1,1,2,1],
  [1,2,1,1,1,1,2,1,1,2,1,1,1,1,1,1,1,1,2,1,1,2,1,1,1,1,2,1],
  [1,2,2,2,2,2,2,1,1,2,2,2,2,1,1,2,2,2,2,1,1,2,2,2,2,2,2,1],
  [1,1,1,1,1,1,2,1,1,1,1,1,0,1,1,0,1,1,1,1,1,2,1,1,1,1,1,1],
  [5,0,0,0,0,1,2,1,1,1,1,1,0,1,1,0,1,1,1,1,1,2,1,0,0,0,0,5],
  [5,0,0,0,0,1,2,1,1,0,0,0,0,0,0,0,0,0,0,1,1,2,1,0,0,0,0,5],
  [5,0,0,0,0,1,2,1,1,0,1,1,1,6,6,1,1,1,0,1,1,2,1,0,0,0,0,5],
  [1,1,1,1,1,1,2,1,1,0,1,7,7,7,7,7,7,1,0,1,1,2,1,1,1,1,1,1],
  [5,0,0,0,0,0,2,0,0,0,1,7,7,7,7,7,7,1,0,0,0,2,0,0,0,0,0,5],
  [1,1,1,1,1,1,2,1,1,0,1,7,7,7,7,7,7,1,0,1,1,2,1,1,1,1,1,1],
  [5,0,0,0,0,1,2,1,1,0,1,1,1,1,1,1,1,1,0,1,1,2,1,0,0,0,0,5],
  [5,0,0,0,0,1,2,1,1,0,0,0,0,4,4,0,0,0,0,1,1,2,1,0,0,0,0,5],
  [5,0,0,0,0,1,2,1,1,0,1,1,1,1,1,1,1,1,0,1,1,2,1,0,0,0,0,5],
  [1,1,1,1,1,1,2,1,1,0,1,1,1,1,1,1,1,1,0,1,1,2,1,1,1,1,1,1],
  [1,2,2,2,2,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,2,1],
  [1,2,1,1,1,1,2,1,1,1,1,1,2,1,1,2,1,1,1,1,1,2,1,1,1,1,2,1],
  [1,2,1,1,1,1,2,1,1,1,1,1,2,1,1,2,1,1,1,1,1,2,1,1,1,1,2,1],
  [1,3,2,2,1,1,2,2,2,2,2,2,2,8,8,2,2,2,2,2,2,2,1,1,2,2,3,1],
  [1,1,1,2,1,1,2,1,1,2,1,1,1,1,1,1,1,1,2,1,1,2,1,1,2,1,1,1],
  [1,1,1,2,1,1,2,1,1,2,1,1,1,1,1,1,1,1,2,1,1,2,1,1,2,1,1,1],
  [1,2,2,2,2,2,2,1,1,2,2,2,2,1,1,2,2,2,2,1,1,2,2,2,2,2,2,1],
  [1,2,1,1,1,1,1,1,1,1,1,1,2,1,1,2,1,1,1,1,1,1,1,1,1,1,2,1],
  [1,2,1,1,1,1,1,1,1,1,1,1,2,1,1,2,1,1,1,1,1,1,1,1,1,1,2,1],
  [1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1],
  [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
];

// ── Character colours ──────────────────────────────────────────────────────

/// Default colour of Pac-Man. Can be overridden in [Settings].
const Color pacmanColor = Color(0xFFFFFF00);

/// Default colour of Blinky (red ghost). Can be overridden in [Settings].
const Color blinkyColor = Color(0xFFFF0000);

/// Default colour of Pinky (pink ghost). Can be overridden in [Settings].
const Color pinkyColor = Color(0xFFFFB7FF);

/// Default colour of Inky (cyan ghost). Can be overridden in [Settings].
const Color inkyColor = Color(0xFF00FFFF);

/// Default colour of Clyde (orange ghost). Can be overridden in [Settings].
const Color clydeColor = Color(0xFFFFB751);

/// Default colour of the maze walls. Can be overridden in [Settings].
const Color mapColor = Color(0xFF2121FF);

// ── Text styles ────────────────────────────────────────────────────────────

/// Bold Pac-Font style used for all screen headings in the app bar.
const TextStyle headerTextStyle = TextStyle(
  fontFamily: 'Pacfont',
  fontSize: 25,
  fontWeight: FontWeight.bold,
);

// ── Anonymous / guest defaults ─────────────────────────────────────────────

/// Firebase UID reserved for the anonymous guest account stored in the DB.
const String anonymousId = '0';

/// Display name shown when no user is signed in.
const String anonymousName = 'Guest';

/// High-score placeholder for a guest session.
const int anonymousHighScore = 0;

/// E-mail placeholder for a guest session.
const String anonymousEmail = 'name@gmail.com';

/// Bonus-table initial values for a guest session – all bonuses at zero.
const Map<BonusType, int> anonymousBonusTable = {
  BonusType.apple: 0,
  BonusType.bell: 0,
  BonusType.cherry: 0,
  BonusType.galaxian: 0,
  BonusType.key: 0,
  BonusType.melon: 0,
  BonusType.orange: 0,
  BonusType.strawberry: 0,
};