import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacman_application/utils/constants.dart';
import 'package:pacman_application/database/game_user.dart';
import 'package:pacman_application/database/session.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/utils/sidebar.dart';

/// Shows all registered players ranked by their all-time high score.
///
/// Data is fetched from Firebase Realtime Database once when the screen
/// mounts. The top three entries are highlighted with gold, silver, and
/// bronze trophy icons respectively; remaining entries show a numbered
/// circular badge. The currently signed-in player's row is highlighted.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => LeaderboardScreenState();
}

class LeaderboardScreenState extends State<LeaderboardScreen> {
  // ── Fields ───────────────────────────────────────────────────────────────

  /// All users fetched from the database. Sorted by high score at build time.
  final List<GameUser> _users = [];

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _loadUsers();

    // Trigger a rebuild after 500 ms to display any users whose async data
    // fetch has completed by then.
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Sort descending by high score each time the widget rebuilds.
    final sortedUsers = List<GameUser>.from(_users)
      ..sort((a, b) => b.highScore.compareTo(a.highScore));

    return Scaffold(
      appBar: Appbar(
        context: context,
        header: Text('LEADERBOARD', style: headerTextStyle),
      ),
      drawer: const Sidebar(),
      body: SafeArea(
        child: ListView.builder(
          itemCount: sortedUsers.length,
          itemBuilder: (_, index) {
            final user = sortedUsers[index];
            final rank = index + 1;

            return ListTile(
              // Highlight the current user's row.
              selected: user == currentUser,
              leading: _rankBadge(rank),
              title: Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              trailing: Text(
                '${user.highScore}',
                style: TextStyle(
                  color: Colors.yellow[900],
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  /// Fetches all user records from `users/` in Firebase and populates
  /// [_users], skipping the anonymous-guest placeholder (uid `"0"`).
  void _loadUsers() async {
    final ref = FirebaseDatabase.instance.ref('users');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      for (final child in snapshot.children) {
        if (child.key != '0') {
          _users.add(GameUser.fromUid(uid: child.key!));
        }
      }
    }

    if (mounted) setState(() {});
  }

  /// Returns a rank indicator widget.
  ///
  /// Ranks 1–3 receive a trophy icon in gold, silver, or bronze. All other
  /// ranks receive a circular avatar with the rank number.
  Widget _rankBadge(int rank) => Container(
    margin: const EdgeInsets.all(2),
    child: switch (rank) {
      1 => const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 32),
      2 => const Icon(Icons.emoji_events, color: Color(0xFFC0C0C0), size: 28),
      3 => const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 24),
      _ => CircleAvatar(
        backgroundColor: Colors.grey[800],
        radius: 15,
        child: Text(
          '$rank',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    },
  );
}