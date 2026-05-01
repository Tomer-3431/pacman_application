
import 'dart:ui';

enum BonusType {
  apple(Color(0xFFB71C1C), Color(0xFFFF0000)),
  bell(Color(0xFFDBC000), Color(0xFFFFFF00)),
  cherry(Color(0xFFB71C1C), Color(0xFFFF0000)),
  galaxian(Color(0xFF0D47A1), Color(0xFF0000FF)),
  key(Color(0xFF01579B), Color(0xFF47B7FF)),
  melon(Color(0xFF81C784), Color(0xFF00FF00)),
  orange(Color.fromARGB(255, 46, 16, 0), Color(0xFFFFB751)),
  strawberry(Color(0xFFB71C1C), Color(0xFFFF0000));

  final Color bgColor;
  final Color borderColor;

  const BonusType(this.bgColor, this.borderColor);
}