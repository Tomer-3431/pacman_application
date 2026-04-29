import 'package:flutter/material.dart';
import 'package:pacman_application/game/controller/dpad_button.dart';
import 'package:pacman_application/game/direction.dart';

class Controller extends StatefulWidget {
  const Controller({
    super.key,
    required this.onDirectionChanged,
  });

  final void Function(Direction direction) onDirectionChanged;

  @override
  State<Controller> createState() => _ControllerState();
}

class _ControllerState extends State<Controller> {
  @override
  Widget build(BuildContext context) {
    final btnSize = (MediaQuery.of(context).size.width * 0.22).clamp(60, 85);
    return SizedBox(
      height: btnSize * 3 + 8,
      child: dpad(btnSize.toDouble()),
    );
  }

  Widget dpad(double btnSize) => Stack(
    alignment: Alignment.center,
    children: [
      Positioned(
        top: 0,
        child: DpadButton(
          size: btnSize,
          icon: Icons.arrow_drop_up,
          onPressed: () => widget.onDirectionChanged(Direction.up),
        ),
      ),
      Positioned(
        top: btnSize + 10,
        child: DpadButton(
          size: btnSize,
          icon: Icons.arrow_drop_down,
          onPressed: () => widget.onDirectionChanged(Direction.down),
        ),
      ),
      Positioned(
        top: btnSize + 4,
        left: MediaQuery.of(context).size.width / 2 - btnSize * 1.5 - 10,
        child: DpadButton(
          size: btnSize,
          icon: Icons.arrow_left,
          onPressed: () => widget.onDirectionChanged(Direction.left),
        ),
      ),
      Positioned(
        top: btnSize + 4,
        left: MediaQuery.of(context).size.width / 2 + btnSize * 0.5 + 10,
        child: DpadButton(
          size: btnSize,
          icon: Icons.arrow_right,
          onPressed: () => widget.onDirectionChanged(Direction.right),
        ),
      ),
    ],
  );
}
