
import 'package:flutter/material.dart';

class EndGameButtons extends StatefulWidget {
  final double size;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const EndGameButtons({super.key, required this.size, required this.onRetry, required this.onExit});

  @override
  State<StatefulWidget> createState() => EndGameButtonsState();
}

class EndGameButtonsState extends State<EndGameButtons> {
  bool _isRetryPressed = false;
  bool _isExitPressed = false;

  void _startRetryPress() {
    setState(() {
      _isRetryPressed = true;
    });
    widget.onRetry();
  }

  void _endRetryPress() {
    setState(() {
      _isRetryPressed = false;
    });
  }

  void _startExitPress(){
    setState(() {
      _isExitPressed = true;
    });
    widget.onExit();
  }

  void _endExitPress() {
    setState(() {
      _isExitPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      GestureDetector(
        onTapDown: (_) => _startRetryPress(),
        onTapUp: (_) => _endRetryPress(),
        onTapCancel: _endRetryPress,
        child: AnimatedContainer(
          margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
          duration: Duration(microseconds: 80),
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: _isRetryPressed ? Colors.red[300] : Colors.red[900],
            border: Border.all(
              color: _isRetryPressed ? Colors.amber : Colors.grey[700]!,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isRetryPressed
                ? []
                : [
                    BoxShadow(
                      color: const Color(0x7F000000),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              "RETRY",
              style: TextStyle(
                fontSize: 40,
                fontFamily: "PressStart",
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
          ),
        ),
      ),
      GestureDetector(
        onTapDown: (_) => _startExitPress(),
        onTapUp: (_) => _endExitPress(),
        onTapCancel: _endExitPress,
        child: AnimatedContainer(
          margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
          duration: Duration(microseconds: 80),
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: _isExitPressed ? Colors.red[300] : Colors.red[900],
            border: Border.all(
              color: _isExitPressed ? Colors.amber : Colors.grey[700]!,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isExitPressed
                ? []
                : [
                    BoxShadow(
                      color: const Color(0x7F000000),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              "EXIT",
              style: TextStyle(
                fontSize: 40,
                fontFamily: "PressStart",
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
