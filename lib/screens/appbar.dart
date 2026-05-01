import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pacman_application/database/game_user.dart';
import 'package:pacman_application/screens/login.dart';
import 'package:pacman_application/database/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Appbar extends AppBar {
  Appbar({super.key, required this.context, this.header = const Text(""), this.canLogout = true});

  final Text header;
  final BuildContext context;

  @override
  Widget? get title => Center(child: header);

  void signOut() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.remove("lastUser/uid");
    prefs.remove("lastUser/name");
    prefs.remove("lastUser/highScore");
    prefs.remove("lastUser/email");
  }

  final bool canLogout;

  @override
  List<Widget>? get actions => canLogout
      ? [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              currentUser = GameUser(uid: "0");
              signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (final BuildContext context) => Login(),
                ),
              );
            },
            icon: Icon(Icons.logout, color: Colors.black),
          ),
        ]
      : [];

  @override
  double? get elevation => 8;

  @override
  ShapeBorder? get shape => RoundedRectangleBorder(
    side: BorderSide(width: 2),
    borderRadius: BorderRadiusGeometry.vertical(bottom: Radius.circular(16)),
  );
}
