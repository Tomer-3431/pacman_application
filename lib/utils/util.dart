import 'dart:math';

double dist(num x, num y) {
  return sqrt((x * x + y * y).abs());
}

T cast<T extends Object> (dynamic object) => object as T;
T? tryCast<T extends Object> (dynamic object) => object is T ? object : null;
