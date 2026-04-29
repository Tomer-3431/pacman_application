import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:pacman_application/util.dart';

class GameUser {
  final String uid;
  String name = "Guest!";
  int _highScore = 0;
  int get highScore => _highScore;
  String email = "name@email.com";

  set highScore(int score) {
    _highScore = score;
    updateScore(score);
  }

  void updateScore(int score) async {
    final ref = FirebaseDatabase.instance.ref("users/$uid");
    await ref.update({"highScore": score});
  }

  GameUser({
    required this.uid,
    this.name = "Guest!",
    int? highScore,
    this.email = "name@email.com",
  }) {
    this.highScore = highScore ?? 0;
  }

  GameUser.fromUid({required this.uid}) {
    try {
      final ref = FirebaseDatabase.instance.ref("users/$uid");
      setData(ref);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print("error ${e.code}");
        print("defaulted user");
      }
      GameUser(uid: uid);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print("error ${e.code}");
        print("defaulted user");
      }
      GameUser(uid: uid);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  bool haveInitalized() {
    return name != "Guest!";
  }

  void setData(DatabaseReference ref) async {
    var event = await ref.child("name").once();
    name = tryCast(event.snapshot.value) ?? "";
    event = await ref.child("highScore").once();
    highScore = tryCast(event.snapshot.value) ?? 0;
    event = await ref.child("email").once();
    email = tryCast(event.snapshot.value) ?? "";
  }
}
