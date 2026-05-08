import 'package:flutter/material.dart';
import 'package:pacman_application/game/controller/dpad_button.dart';
import 'package:pacman_application/game/direction.dart';

/// An on-screen D-pad controller rendered as four circular [DpadButton]s.
///
/// Calls [onDirectionChanged] with the appropriate [Direction] whenever a
/// button is pressed (and continues calling it repeatedly while held, since
/// [DpadButton] has built-in repeat behaviour).
class Controller extends StatefulWidget {
  const Controller({
    super.key,
    required this.onDirectionChanged,
  });

  /// Called with the new [Direction] each time a D-pad button is activated.
  final void Function(Direction direction) onDirectionChanged;

  @override
  State<Controller> createState() => _ControllerState();
}

class _ControllerState extends State<Controller> {
  @override
  Widget build(BuildContext context) {
    // Button size scales with screen width, clamped to a sensible range.
    final buttonSize =
        (MediaQuery.of(context).size.width * 0.22).clamp(60, 85).toDouble();
    return SizedBox(
      height: buttonSize * 3 + 8,
      child: _buildDpad(buttonSize),
    );
  }

  /// Lays out the four direction buttons in a cross / plus shape.
  Widget _buildDpad(double buttonSize) => Stack(
    alignment: Alignment.center,
    children: [
      // Up button — top centre.
      Positioned(
        top: 0,
        child: DpadButton(
          size: buttonSize,
          icon: Icons.arrow_drop_up,
          onPressed: () => widget.onDirectionChanged(Direction.up),
        ),
      ),
      // Down button — bottom centre.
      Positioned(
        top: buttonSize + 10,
        child: DpadButton(
          size: buttonSize,
          icon: Icons.arrow_drop_down,
          onPressed: () => widget.onDirectionChanged(Direction.down),
        ),
      ),
      // Left button — middle left.
      Positioned(
        top: buttonSize + 4,
        left: MediaQuery.of(context).size.width / 2 - buttonSize * 1.5 - 10,
        child: DpadButton(
          size: buttonSize,
          icon: Icons.arrow_left,
          onPressed: () => widget.onDirectionChanged(Direction.left),
        ),
      ),
      // Right button — middle right.
      Positioned(
        top: buttonSize + 4,
        left: MediaQuery.of(context).size.width / 2 + buttonSize * 0.5 + 10,
        child: DpadButton(
          size: buttonSize,
          icon: Icons.arrow_right,
          onPressed: () => widget.onDirectionChanged(Direction.right),
        ),
      ),
    ],
  );
}