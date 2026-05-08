
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pacman_application/database/session.dart';
import 'package:pacman_application/utils/bonus_type.dart';

class BonusCard extends StatefulWidget {
  const BonusCard(this.i, {super.key});

  final int i;

  @override
  State<BonusCard> createState() => BonusCardState();
}

class BonusCardState extends State<BonusCard> {
  static const String startDir = "assets/game/bonuses/";
  static const String endDir = ".png";

  bool isPressed = false;
  bool isTimerFinish = false;
  late BonusType bonus = BonusType.values[widget.i];
  bool haveGot = false;
  int numGotten = 0;

  @override
  void initState() {
    super.initState();

    numGotten = currentUser.bonusTable[bonus]!;
    haveGot = numGotten > 0;
  }

  void bonusDialog(BuildContext context) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: SizedBox(
        height: (MediaQuery.of(context).size.height / 3).clamp(370, 600),
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: BoxBorder.all(color: bonus.borderColor, width: 5),
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Stack(
                alignment: AlignmentGeometry.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(
                          color: bonus.bgColor.withAlpha(100),
                          spreadRadius: 4,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: ClipRect(
                      clipBehavior: Clip.antiAlias,
                      child: image(0.2),
                    ),
                  ),
                  image(0.2),
                ],
              ),

              Text(
                bonus.name.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.grey[800],
                ),
              ),

              Spacer(),

              Text(
                "You have collected $numGotten of that collectable",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    ),
  );

  Image image(double scale) => Image.asset(
    "$startDir${BonusType.values[widget.i].name}$endDir",
    scale: scale,
    color: haveGot ? null : Colors.grey,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => setState(() {
        isPressed = true;
        Timer(Duration(milliseconds: 200), () => isTimerFinish = true);
        if (haveGot) {
          bonusDialog(context);
        }
      }),
      onTapUp: (details) {
        if (!isTimerFinish) {
          Timer(Duration(milliseconds: 200), () {
            setState(() {
              isTimerFinish = false;
              isPressed = false;
            });
          });
        } else {
          setState(() {
            isTimerFinish = false;
            isPressed = false;
          });
        }
      },
      onTapCancel: () {
        if (!isTimerFinish) {
          Timer(Duration(milliseconds: 300), () {
            setState(() {
              isTimerFinish = false;
              isPressed = false;
            });
          });
        } else {
          setState(() {
            isTimerFinish = false;
            isPressed = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey[800]!,
              offset: isPressed ? Offset(0, 2) : Offset(0, 10),
              spreadRadius: isPressed ? 1 : 5,
            ),
            BoxShadow(
              color: Colors.grey[800]!,
              offset: isPressed ? Offset(0, 0) : Offset(-4, 1),
              spreadRadius: isPressed ? 0 : 1,
            ),
            BoxShadow(
              color: Colors.grey[800]!,
              offset: isPressed ? Offset(0, 0) : Offset(4, 1),
              spreadRadius: isPressed ? 0 : 1,
            ),
          ],
          border: BoxBorder.all(
            color: haveGot ? bonus.borderColor : Colors.grey[800]!,
            width: 5,
          ),
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Colors.yellow[100],
        ),
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(5),
        child: AnimatedSlide(
          duration: Duration(milliseconds: 100),
          offset: isPressed ? Offset(0, 0.05) : Offset(0, 0),
          curve: Curves.easeInOut,
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: AlignmentGeometry.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      boxShadow: [
                        BoxShadow(
                          color: bonus.bgColor.withAlpha(100),
                          spreadRadius: 4,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: ClipRect(
                      clipBehavior: Clip.antiAlias,
                      child: image(0.4),
                    ),
                  ),
                  image(0.4),
                ],
              ),
              Text(
                bonus.name.toUpperCase(),
                style: TextStyle(fontSize: 16, color: Colors.grey[800], decoration: haveGot ? null :TextDecoration.lineThrough),
              ),
            ],
          ),
        ),
      ),
    );
  }
}