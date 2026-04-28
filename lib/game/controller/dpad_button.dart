import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

class DpadButton extends StatefulWidget {
  final double size;
  final IconData icon;
  final VoidCallback onPressed;

  const DpadButton({
    super.key,
    required this.size,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<DpadButton> createState() => DpadButtonState();
}

class DpadButtonState extends State<DpadButton> {
  bool _isPressed = false;
  Timer? _repeatTimer;

  void _startPress() {
    setState(() {
      _isPressed = true;
    });
    widget.onPressed();
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      widget.onPressed();
    });
  }

  void _endPress() {
    setState(() {
      _isPressed = false;
    });
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _startPress(),
    onTapUp: (_) => _endPress(),
    onTapCancel: () => _endPress(),
    child: AnimatedContainer(
      duration: Duration(microseconds: 80),
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isPressed ? Colors.grey[700] : Colors.grey[900],
        border: Border.all(color: _isPressed ? Colors.amber : Colors.grey[700]!, width: 2),
        boxShadow: _isPressed
            ? []
            : [
          BoxShadow(
            color: const Color(0x7F000000),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Icon(
        widget.icon,
        color: _isPressed ? Colors.amber : Colors.white,
        size: widget.size * 0.55,
      ),
    ),
  );
}
