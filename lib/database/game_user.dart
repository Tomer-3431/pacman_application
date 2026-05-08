import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:pacman_application/utils/constants.dart';
import 'package:pacman_application/utils/util.dart';
import 'package:pacman_application/utils/bonus_type.dart';

class GameUser {
  final String uid;
  String name = anonymousName;
  int _highScore = anonymousHighScore;
  int get highScore => _highScore;
  String email = anonymousEmail;
  Map<BonusType, int> bonusTable = anonymousBonusTable;

  set highScore(int score) {
    _highScore = score;
    updateScore(score);
  }

  void updateScore(int score) async {
    final ref = FirebaseDatabase.instance.ref("users/$uid");
    await ref.update({"highScore": score});
  }

  void addBonus(BonusType bonus) {
    bonusTable[bonus] = bonusTable[bonus]! + 1;
    updateBonusTable(bonus);
  }

  void updateBonusTable(BonusType bonus) async {
    final ref = FirebaseDatabase.instance.ref("users/$uid/bonusTable");
    await ref.update({bonus.name: bonusTable[bonus]});
  }

  GameUser({
    required this.uid,
    this.name = anonymousName,
    int? highScore,
    this.email = anonymousEmail,
    this.bonusTable = anonymousBonusTable,
  }) {
    _highScore = highScore ?? anonymousHighScore;
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
    return name != anonymousName;
  }

  void setData(DatabaseReference ref) async {
    var event = await ref.child("name").once();
    name = tryCast(event.snapshot.value) ?? "";
    event = await ref.child("highScore").once();
    _highScore = tryCast(event.snapshot.value) ?? 0;
    event = await ref.child("email").once();
    email = tryCast(event.snapshot.value) ?? "";
    bonusTable = <BonusType, int>{};
    final entries = await Future.wait(
      BonusType.values.map((bonus) {
        return _getBonusData(bonus, ref);
      }),
    );
    bonusTable.addEntries(entries);
  }

  Future<MapEntry<BonusType, int>> _getBonusData(
    BonusType bonus,
    DatabaseReference ref,
  ) async {
    var event = await ref.child("bonusTable").child(bonus.name).once();
    return MapEntry(bonus, tryCast(event.snapshot.value) ?? 0);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is GameUser && uid == other.uid);
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return """
      uid: $uid
      name: $name
      high score: $highScore
      email: $email
      bonus table: $bonusTable
    """;
  }
}
