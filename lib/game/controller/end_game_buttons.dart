import 'package:flutter/material.dart';

/// A pair of styled buttons shown at the end of the game: **RETRY** and **EXIT**.
///
/// Each button uses an [AnimatedContainer] to provide a pressed-state visual
/// effect. [onRetry] and [onExit] are called as soon as the finger touches
/// the button (not on release), matching arcade game feel.
class EndGameButtons extends StatefulWidget {
  const EndGameButtons({
    super.key,
    required this.size,
    required this.onRetry,
    required this.onExit,
  });

  /// Height of each button in logical pixels.
  final double size;

  /// Called when the RETRY button is tapped.
  final VoidCallback onRetry;

  /// Called when the EXIT button is tapped.
  final VoidCallback onExit;

  @override
  State<EndGameButtons> createState() => _EndGameButtonsState();
}

class _EndGameButtonsState extends State<EndGameButtons> {
  // ── State ─────────────────────────────────────────────────────────────────

  bool _isRetryPressed = false;
  bool _isExitPressed = false;

  // ── Gesture handlers ──────────────────────────────────────────────────────

  void _startRetryPress() {
    setState(() => _isRetryPressed = true);
    widget.onRetry();
  }

  void _endRetryPress() => setState(() => _isRetryPressed = false);

  void _startExitPress() {
    setState(() => _isExitPressed = true);
    widget.onExit();
  }

  void _endExitPress() => setState(() => _isExitPressed = false);

  // ── Widget ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      _buildButton(
        label: "RETRY",
        isPressed: _isRetryPressed,
        onStart: _startRetryPress,
        onEnd: _endRetryPress,
        bottomMargin: 10,
      ),
      _buildButton(
        label: "EXIT",
        isPressed: _isExitPressed,
        onStart: _startExitPress,
        onEnd: _endExitPress,
        bottomMargin: 0,
      ),
    ],
  );

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Builds a single labelled button with pressed-state animation.
  Widget _buildButton({
    required String label,
    required bool isPressed,
    required VoidCallback onStart,
    required VoidCallback onEnd,
    required double bottomMargin,
  }) {
    return GestureDetector(
      onTapDown: (_) => onStart(),
      onTapUp: (_) => onEnd(),
      onTapCancel: onEnd,
      child: AnimatedContainer(
        margin: EdgeInsets.fromLTRB(20, 10, 20, bottomMargin),
        duration: const Duration(microseconds: 80),
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: isPressed ? Colors.red[300] : Colors.red[900],
          border: Border.all(
            color: isPressed ? Colors.amber : Colors.grey[700]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isPressed
              ? []
              : const [
                  BoxShadow(
                    color: Color(0x7F000000),
                    offset: Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 40,
              fontFamily: "PressStart",
              fontWeight: FontWeight.bold,
              color: Colors.blue[900],
            ),
          ),
        ),
      ),
    );
  }
}