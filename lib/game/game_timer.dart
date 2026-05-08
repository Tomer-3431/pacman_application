/// A simple countdown timer used to schedule in-game events.
///
/// Create a [GameTimer] with a duration in seconds and an optional [onEnd]
/// callback. Call [start] to activate it, then call [update] every game tick
/// with the real elapsed delta-time. When the accumulated time reaches
/// [duration], [onEnd] is fired and the timer either stops or restarts
/// depending on [isLoop].
class GameTimer {
  /// Creates a [GameTimer].
  ///
  /// [duration] – seconds until [onEnd] fires.
  /// [onEnd]    – callback invoked when the timer expires.
  /// [isOn]     – whether the timer starts in an active state.
  /// [isLoop]   – if `true` the timer automatically restarts after firing.
  GameTimer(
    this.duration, {
    this.onEnd,
    this.isOn = false,
    this.isLoop = false,
  }) : _clock = 0;

  // ── Configuration ────────────────────────────────────────────────────────

  /// Total seconds that must elapse before [onEnd] is triggered.
  final double duration;

  /// Callback invoked when the timer reaches [duration]. May be `null`.
  final void Function()? onEnd;

  /// Whether the timer restarts automatically after firing.
  final bool isLoop;

  // ── State ────────────────────────────────────────────────────────────────

  /// Seconds accumulated since the timer last started or reset.
  double _clock;

  /// Whether the timer is currently counting.
  bool isOn;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Advances the timer by [dt] seconds and fires [onEnd] if the duration is reached.
  void update(double dt) {
    if (!isOn) return;

    _clock += dt;

    if (_clock >= duration) {
      onEnd?.call();
      _reset();
    }
  }

  /// Activates the timer so it begins counting on the next [update] call.
  void start() {
    isOn = true;
  }

  /// Pauses the timer without resetting its accumulated time.
  void pause() {
    isOn = false;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  /// Resets accumulated time and stops (or loops) the timer.
  void _reset() {
    isOn = isLoop;
    _clock = 0;
  }
}
