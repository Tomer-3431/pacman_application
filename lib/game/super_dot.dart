import 'package:flutter/material.dart';

class SuperDot extends StatelessWidget {
  final int x;
  final int y;
  bool isEaten = false; 
  final void Function() onEaten;

  SuperDot(this.x, this.y, {super.key, required this.onEaten}) {
    isEaten = false;
  }

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints.tight(Size(7, 7)),
    decoration: BoxDecoration(
      color: Colors.amber[900],
      shape: BoxShape.circle,
    ),
  );


  Widget showOnStack(double tileSize) {
    return Positioned(
      left: (x + 0.5) * tileSize,
      top: (y + 0.5) * tileSize,
      child: isEaten ? Container() : this,
    );
  }

  void checkIfEaten(double pacmanX, double pacmanY) {
    if (!isEaten && (pacmanX - x).abs() < 0.5 && (pacmanY - y).abs() < 0.5) {
      eat();
    }
  }

  void eat() {
    onEaten();
    isEaten = true;
  }

  void reset() {
    isEaten = false;
  }
}