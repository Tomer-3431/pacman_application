import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pacman_application/database/session.dart';
import 'package:pacman_application/utils/bonus_type.dart';

/// A card widget shown in the [CollectablesScreen] grid for a single
/// [BonusType].
///
/// Cards for items the player has not yet collected are rendered in
/// greyscale with a strikethrough label. Tapping a collected card opens a
/// detail [AlertDialog] showing the bonus image and how many times it has
/// been collected.
///
/// The card also features a subtle press animation: it sinks slightly on
/// tap-down and rises back on tap-up, mimicking a physical button.
class BonusCard extends StatefulWidget {
  const BonusCard(this.i, {super.key});

  /// Index into [BonusType.values] that identifies which bonus this card
  /// represents.
  final int i;

  @override
  State<BonusCard> createState() => BonusCardState();
}

class BonusCardState extends State<BonusCard> {
  // ── Constants ─────────────────────────────────────────────────────────

  /// Asset directory that contains bonus PNG images.
  static const String _assetDir = 'assets/game/bonuses/';

  /// File extension for bonus images.
  static const String _assetExt = '.png';

  // ── Fields ────────────────────────────────────────────────────────────

  /// Whether the card is currently being pressed.
  bool _isPressed = false;

  /// Set to `true` 200 ms after tap-down; prevents a race where tap-up
  /// fires before the minimum press animation duration has elapsed.
  bool _isTimerFinished = false;

  /// The [BonusType] this card represents.
  late final BonusType _bonus;

  /// Whether the player has collected this bonus at least once.
  bool _hasCollected = false;

  /// The total number of times the player has collected this bonus.
  int _collectedCount = 0;

  // ── Lifecycle ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _bonus = BonusType.values[widget.i];
    _collectedCount = currentUser.bonusTable[_bonus]!;
    _hasCollected = _collectedCount > 0;
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() {
        _isPressed = true;
        Timer(
          const Duration(milliseconds: 200),
          () => _isTimerFinished = true,
        );
        if (_hasCollected) _showBonusDialog(context);
      }),
      onTapUp: (_) {
        if (!_isTimerFinished) {
          Timer(const Duration(milliseconds: 200), () {
            setState(() {
              _isTimerFinished = false;
              _isPressed = false;
            });
          });
        } else {
          setState(() {
            _isTimerFinished = false;
            _isPressed = false;
          });
        }
      },
      onTapCancel: () {
        if (!_isTimerFinished) {
          Timer(const Duration(milliseconds: 300), () {
            setState(() {
              _isTimerFinished = false;
              _isPressed = false;
            });
          });
        } else {
          setState(() {
            _isTimerFinished = false;
            _isPressed = false;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey[800]!,
              offset: _isPressed ? const Offset(0, 2) : const Offset(0, 10),
              spreadRadius: _isPressed ? 1 : 5,
            ),
            BoxShadow(
              color: Colors.grey[800]!,
              offset: _isPressed ? Offset.zero : const Offset(-4, 1),
              spreadRadius: _isPressed ? 0 : 1,
            ),
            BoxShadow(
              color: Colors.grey[800]!,
              offset: _isPressed ? Offset.zero : const Offset(4, 1),
              spreadRadius: _isPressed ? 0 : 1,
            ),
          ],
          border: BoxBorder.all(
            color: _hasCollected ? _bonus.borderColor : Colors.grey[800]!,
            width: 5,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: Colors.yellow[100],
        ),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(5),
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 100),
          offset: _isPressed ? const Offset(0, 0.05) : Offset.zero,
          curve: Curves.easeInOut,
          child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _bonusImageWithGlow(scale: 0.4),
              Text(
                _bonus.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  decoration:
                      _hasCollected ? null : TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────

  /// Opens the detail dialog for this bonus, showing a larger image and
  /// the collected count.
  void _showBonusDialog(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      content: SizedBox(
        height: (MediaQuery.of(context).size.height / 3).clamp(370, 600),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: BoxBorder.all(color: _bonus.borderColor, width: 5),
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
          ),
          child: Column(
            spacing: 20,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _bonusImageWithGlow(scale: 0.2),
              Text(
                _bonus.name.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Text(
                'You have collected $_collectedCount of that collectable',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    ),
  );

  /// Returns the bonus [Image] asset at the given [scale], tinted grey when
  /// the player has not yet collected this bonus.
  Image _bonusImage(double scale) => Image.asset(
    '$_assetDir${_bonus.name}$_assetExt',
    scale: scale,
    color: _hasCollected ? null : Colors.grey,
  );

  /// Stacks [_bonusImage] on top of a coloured glow shadow to create a
  /// neon-light effect.
  Widget _bonusImageWithGlow({required double scale}) => Stack(
    alignment: AlignmentGeometry.center,
    children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: _bonus.bgColor.withAlpha(100),
              spreadRadius: 4,
              offset: Offset.zero,
            ),
          ],
        ),
        child: ClipRect(
          clipBehavior: Clip.antiAlias,
          child: _bonusImage(scale),
        ),
      ),
      _bonusImage(scale),
    ],
  );
}