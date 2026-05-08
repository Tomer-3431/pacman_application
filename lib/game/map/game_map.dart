import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/dot.dart';
import 'package:pacman_application/game/super_dot.dart';

/// Represents the static layout and collectible state of the game map.
///
/// The map is a 2-D grid of integer tile codes (see the `k*` constants).
/// [GameMap] parses the raw grid on construction, building [dots] and
/// [superDots] lists that track which collectibles are still available.
///
/// Call [reset] between rounds to restore all collectibles.
class GameMap {
  /// Creates a [GameMap] from [map] and registers the two collectible callbacks.
  ///
  /// [onDotEaten]      – called by each [Dot] when Pac-Man eats it.
  /// [onSuperDotEaten] – called by each [SuperDot] when Pac-Man eats it.
  GameMap({
    required this.map,
    required this.onDotEaten,
    required this.onSuperDotEaten,
  }) {
    _init();
  }

  // ── Tile-type constants ────────────────────────────────────────────────────

  /// An empty passable tile with no collectible.
  static const int kEmpty = 0;

  /// A solid wall tile that blocks all movement.
  static const int kWall = 1;

  /// A small dot collectible.
  static const int kSmallDot = 2;

  /// A large power-pellet collectible.
  static const int kSuperDot = 3;

  /// A bonus-item spawn tile.
  static const int kBonus = 4;

  /// A tunnel tile: characters that reach the edge wrap to the other side.
  static const int kTunnel = 5;

  /// The ghost-house door — impassable for Pac-Man (except upward exit).
  static const int kGhostHouseDoor = 6;

  /// The interior of the ghost house where ghosts respawn.
  static const int kGhostHouseInterior = 7;

  /// Pac-Man's starting tile (informational; not used for collision).
  static const int kStartingPosition = 8;

  // ── Dimensions & layout constants ─────────────────────────────────────────

  /// Number of tile columns in the map.
  final int kCols = 28;

  /// Number of tile rows in the map.
  final int kRows = 31;

  /// Pac-Man's initial horizontal position in tile units.
  final double startingX = 13.5;

  /// Pac-Man's initial vertical position in tile units.
  final double startingY = 23;

  /// Horizontal tile coordinate of the ghost-house entrance used for pathfinding.
  final int ghostHouseX = 14;

  /// Vertical tile coordinate of the ghost-house entrance used for pathfinding.
  final int ghostHouseY = 15;

  /// Horizontal tile position where the bonus item appears.
  final double bonusX = 13.5;

  /// Vertical tile position where the bonus item appears.
  final double bonusY = 17;

  /// Asset path for the pre-rendered maze image.
  final String mapAssetPath = 'assets/game/map/map.png';

  // ── Map data ───────────────────────────────────────────────────────────────

  /// The raw 2-D grid of tile codes ([kRows] × [kCols]).
  final List<List<int>> map;

  // ── Collectibles ──────────────────────────────────────────────────────────

  /// All small dots on the map (eaten and uneaten).
  late final List<Dot> dots = [];

  /// All power pellets on the map (eaten and uneaten).
  late final List<SuperDot> superDots = [];

  /// Number of collectibles that have not yet been eaten this round.
  late int remainingDots = dots.length + superDots.length;

  // ── Callbacks ─────────────────────────────────────────────────────────────

  /// Invoked by a [Dot] when Pac-Man collects it.
  final void Function() onDotEaten;

  /// Invoked by a [SuperDot] when Pac-Man collects it.
  final void Function() onSuperDotEaten;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Restores all collectibles and resets [remainingDots] for a new round.
  void reset() {
    for (final dot in dots) {
      dot.reset();
    }
    for (final superDot in superDots) {
      superDot.reset();
    }
    remainingDots = dots.length + superDots.length;
  }

  /// Returns `true` if moving one step in [direction] from ([col], [row])
  /// would enter a wall tile.
  ///
  /// Out-of-bounds targets are treated as walls.
  /// When [isPacman] is `true`, the ghost-house door also acts as a wall
  /// (except when moving upward, which allows exiting the ghost house).
  bool isWall(int col, int row, Direction direction, {bool isPacman = false}) {
    int targetCol = col;
    int targetRow = row;

    switch (direction) {
      case Direction.up:
        targetRow -= 1;
        break;
      case Direction.down:
        targetRow += 1;
        break;
      case Direction.left:
        targetCol -= 1;
        break;
      case Direction.right:
        targetCol += 1;
        break;
    }

    if (targetCol < 0 ||
        targetCol >= kCols ||
        targetRow < 0 ||
        targetRow >= kRows) {
      return true; // out-of-bounds counts as a wall
    }

    return map[targetRow][targetCol] == kWall ||
        (isPacman &&
            map[targetRow][targetCol] == kGhostHouseDoor &&
            direction != Direction.up);
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Scans [map] and populates [dots] and [superDots].
  void _init() {
    for (int row = 0; row < kRows; row++) {
      for (int col = 0; col < kCols; col++) {
        if (map[row][col] == kSmallDot) {
          dots.add(
            Dot(
              col,
              row,
              onEaten: () {
                onDotEaten();
                remainingDots--;
              },
            ),
          );
        } else if (map[row][col] == kSuperDot) {
          superDots.add(
            SuperDot(
              col,
              row,
              onEaten: () {
                onSuperDotEaten();
                remainingDots--;
              },
            ),
          );
        }
      }
    }
  }
}