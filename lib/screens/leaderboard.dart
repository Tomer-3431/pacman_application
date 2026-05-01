import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacman_application/constants.dart';
import 'package:pacman_application/database/game_user.dart';
import 'package:pacman_application/database/session.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/utils/sidebar.dart';

class Leaderboard extends StatefulWidget {
  const Leaderboard({super.key});

  @override
  State<StatefulWidget> createState() => LeaderboardState();
}

class LeaderboardState extends State<Leaderboard> {
  List<GameUser> users = [];

  @override
  void initState() {
    super.initState();

    getUsers();
    Timer(Duration(milliseconds: 200), () {
      setState(() {
        
      });
    });
  }

  void getUsers() async {
    final ref = FirebaseDatabase.instance.ref("users");
    final snapshot = await ref.get();

    if (snapshot.exists) {
      for (var child in snapshot.children) {
        if (child.key != "0") {
          users.add(GameUser.fromUid(uid: child.key!));
        }
      }
    }
    setState(() {
      
    });
  }

  @override
  void dispose() {
    super.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final sortedUsers = List<GameUser>.from(users)
      ..sort((a, b) => b.highScore.compareTo(a.highScore));

    return Scaffold(
      appBar: Appbar(
        context: context,
        header: Text(
          "LEADERBOARD",
          style: headerTextStyle,
        ),
      ),
      drawer: Sidebar(),
      body: SafeArea(
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = sortedUsers[index];
            final rank = index + 1;

            return ListTile(
              selected: user == currentUser,
              leading: _getRankBadge(rank),
              title: Text(
                user.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              trailing: Text(
                "${user.highScore}",
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

  Widget _getRankBadge(int rank) => Container(
    margin: EdgeInsets.all(2),
    child: switch (rank) {
      1 => const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 32),
      2 => const Icon(Icons.emoji_events, color: Color(0xFFC0C0C0), size: 28),
      3 => const Icon(Icons.emoji_events, color: Color(0xFFCD7F32), size: 24),
      _ => CircleAvatar(
        backgroundColor: Colors.grey[800],
        radius: 15,
        child: Text(
          "$rank",
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    },
  );
}
