class GameTimer {
  void Function()? onEnd;
  final double timer;

  GameTimer(this.timer, {this.onEnd, this.isOn = false, this.isLoop = false}) : clock = 0;

  double clock;
  bool isOn;
  bool isLoop;

  void update(double dt) {
    clock += dt;

    if (clock >= timer) {
      onEnd?.call();
      reset();
    }
  }

  void start() {
    isOn = true;
  }

  void pause() {
    isOn = false;
  }

  void reset() {
    isOn = isLoop;
    clock = 0;
  }
}