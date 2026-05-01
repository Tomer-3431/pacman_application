import 'package:pacman_application/game/direction.dart';
import 'package:pacman_application/game/dot.dart';
import 'package:pacman_application/game/super_dot.dart';

class GameMap {
  GameMap({
    required this.map,
    required this.onDotEaten,
    required this.onSuperDotEaten,
  }) {
    init();
  }

  List<List<int>> map;

  static const int kEmpty = 0;
  static const int kWall = 1;
  static const int kSmallDot = 2;
  static const int kSuperDot = 3;
  static const int kBonus = 4;
  static const int kTunnel = 5;
  static const int kGhostHouseDoor = 6;
  static const int kGhostHouseInterior = 7;
  static const int kStartingPosition = 8;

  final String mapAssetPath = 'assets/game/map/map.png';

  final int kCols = 28;
  final int kRows = 31;

  final double startingCol = 13.5;
  final double startingRow = 23;

  final int ghostHouseX = 14;
  final int ghostHouseY = 15;

  final double bonusX = 13.5;
  final double bonusY = 17;

  late final List<Dot> dots = [];
  late final List<SuperDot> superPoints = [];

  final void Function() onDotEaten;
  final void Function() onSuperDotEaten;

  late int leftDots = dots.length + superPoints.length;

  void init() {
    for (int row = 0; row < kRows; row++) {
      for (int col = 0; col < kCols; col++) {
        if (map[row][col] == kSmallDot) {
          dots.add(
            Dot(
              col,
              row,
              onEaten: () {
                onDotEaten();
                leftDots--;
              },
            ),
          );
        } else if (map[row][col] == kSuperDot) {
          superPoints.add(
            SuperDot(
              col,
              row,
              onEaten: () {
                onSuperDotEaten();
                leftDots--;
              },
            ),
          );
        }
      }
    }
  }

  void reset() {
    for (var dot in dots) {
      dot.reset();
    }
    for (var superDot in superPoints) {
      superDot.reset();
    }
    leftDots = dots.length + superPoints.length;
  }

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
      return true; // Treat out of bounds as walls
    }

    return map[targetRow][targetCol] == kWall ||
        (isPacman &&
            map[targetRow][targetCol] == kGhostHouseDoor &&
            direction != Direction.up);
  }
}
