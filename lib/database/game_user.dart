import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:pacman_application/utils/constants.dart';
import 'package:pacman_application/utils/util.dart';
import 'package:pacman_application/utils/bonus_type.dart';

/// Represents a registered (or anonymous) player stored in Firebase
/// Realtime Database under the path `users/<uid>`.
///
/// The class mirrors the following database schema:
/// ```
/// users/
///   <uid>/
///     name        : String
///     email       : String
///     highScore   : int
///     bonusTable/
///       apple     : int
///       bell      : int
///       ...
/// ```
///
/// Use the default constructor when you already have all field values
/// (e.g. after reading from SharedPreferences). Use [GameUser.fromUid]
/// when you only have a Firebase UID and want the data fetched
/// asynchronously from the database.
class GameUser {
  // ── Fields ─────────────────────────────────────────────────────────────

  /// Firebase Auth UID that uniquely identifies this user.
  final String uid;

  /// Player display name shown in the UI and on the leaderboard.
  String name;

  /// The player's registered e-mail address.
  String email;

  /// Maps each [BonusType] to the number of times the player has collected it.
  Map<BonusType, int> bonusTable;

  /// Backing field for [highScore].
  int _highScore;

  // ── Getters / Setters ───────────────────────────────────────────────────

  /// The player's all-time best score.
  int get highScore => _highScore;

  /// Updates [highScore] in memory **and** persists the new value to
  /// Firebase Realtime Database.
  set highScore(int score) {
    _highScore = score;
    _updateScore(score);
  }

  // ── Constructors ────────────────────────────────────────────────────────

  /// Creates a [GameUser] with all fields provided directly.
  ///
  /// [highScore] defaults to [anonymousHighScore] when omitted.
  GameUser({
    required this.uid,
    this.name = anonymousName,
    int? highScore,
    this.email = anonymousEmail,
    this.bonusTable = anonymousBonusTable,
  }) : _highScore = highScore ?? anonymousHighScore;

  /// Creates a [GameUser] by fetching its data from Firebase using [uid].
  ///
  /// Data is loaded asynchronously via [_setData]; the object fields will
  /// hold their default values until that future completes. Use
  /// [haveInitialized] to check whether loading is done.
  GameUser.fromUid({required this.uid})
      : name = anonymousName,
        email = anonymousEmail,
        bonusTable = anonymousBonusTable,
        _highScore = anonymousHighScore {
    try {
      final ref = FirebaseDatabase.instance.ref('users/$uid');
      _setData(ref);
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('FirebaseAuthException ${e.code} – defaulting user');
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('FirebaseException ${e.code} – defaulting user');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // ── Public methods ──────────────────────────────────────────────────────

  /// Returns `true` once the async data fetch initiated by [GameUser.fromUid]
  /// has populated [name] with a real value (i.e. it is no longer the
  /// anonymous placeholder).
  bool haveInitialized() => name != anonymousName;

  /// Increments the collected count for [bonus] in memory and persists the
  /// update to Firebase Realtime Database.
  void addBonus(BonusType bonus) {
    bonusTable[bonus] = bonusTable[bonus]! + 1;
    _updateBonusTable(bonus);
  }

  // ── Private methods ─────────────────────────────────────────────────────

  /// Writes the new [score] to `users/<uid>/highScore` in the database.
  void _updateScore(int score) async {
    final ref = FirebaseDatabase.instance.ref('users/$uid');
    await ref.update({'highScore': score});
  }

  /// Writes the updated count for [bonus] to `users/<uid>/bonusTable/<name>`.
  void _updateBonusTable(BonusType bonus) async {
    final ref = FirebaseDatabase.instance.ref('users/$uid/bonusTable');
    await ref.update({bonus.name: bonusTable[bonus]});
  }

  /// Fetches all user fields from [ref] and populates this object's
  /// properties. Called once during [GameUser.fromUid] construction.
  void _setData(DatabaseReference ref) async {
    var event = await ref.child('name').once();
    name = tryCast(event.snapshot.value) ?? '';

    event = await ref.child('highScore').once();
    _highScore = tryCast(event.snapshot.value) ?? 0;

    event = await ref.child('email').once();
    email = tryCast(event.snapshot.value) ?? '';

    final entries = await Future.wait(
      BonusType.values.map((bonus) => _getBonusEntry(bonus, ref)),
    );
    bonusTable = <BonusType, int>{}..addEntries(entries);
  }

  /// Reads the stored count for a single [bonus] from the database and
  /// returns it as a [MapEntry] suitable for building [bonusTable].
  Future<MapEntry<BonusType, int>> _getBonusEntry(
    BonusType bonus,
    DatabaseReference ref,
  ) async {
    final event = await ref.child('bonusTable').child(bonus.name).once();
    return MapEntry(bonus, tryCast(event.snapshot.value) ?? 0);
  }

  // ── Object overrides ────────────────────────────────────────────────────

  /// Two [GameUser] instances are considered equal when they share the same [uid].
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is GameUser && uid == other.uid);

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() => '''
    uid:         $uid
    name:        $name
    high score:  $highScore
    email:       $email
    bonus table: $bonusTable
  ''';
}