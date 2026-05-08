import 'dart:async';

import 'package:flutter/material.dart';

/// A single circular D-pad button that fires repeatedly while held.
///
/// On press-down [onPressed] fires immediately, then repeats every 80 ms
/// until the finger is lifted.  Visual feedback (colour + border change) is
/// provided via an [AnimatedContainer].
class DpadButton extends StatefulWidget {
  const DpadButton({
    super.key,
    required this.size,
    required this.icon,
    required this.onPressed,
  });

  /// Diameter of the circular button in logical pixels.
  final double size;

  /// Icon displayed in the centre of the button.
  final IconData icon;

  /// Called immediately on press and then every 80 ms while held.
  final VoidCallback onPressed;

  @override
  State<DpadButton> createState() => _DpadButtonState();
}

class _DpadButtonState extends State<DpadButton> {
  // ── State ─────────────────────────────────────────────────────────────────

  bool _isPressed = false;
  Timer? _repeatTimer;

  // ── Gesture handlers ──────────────────────────────────────────────────────

  void _startPress() {
    setState(() => _isPressed = true);
    widget.onPressed();
    _repeatTimer = Timer.periodic(
      const Duration(milliseconds: 80),
      (_) => widget.onPressed(),
    );
  }

  void _endPress() {
    setState(() => _isPressed = false);
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }

  // ── Widget ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _startPress(),
    onTapUp: (_) => _endPress(),
    onTapCancel: () => _endPress(),
    child: AnimatedContainer(
      duration: const Duration(microseconds: 80),
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isPressed ? Colors.grey[700] : Colors.grey[900],
        border: Border.all(
          color: _isPressed ? Colors.amber : Colors.grey[700]!,
          width: 2,
        ),
        boxShadow: _isPressed
            ? []
            : const [
                BoxShadow(
                  color: Color(0x7F000000),
                  offset: Offset(0, 2),
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