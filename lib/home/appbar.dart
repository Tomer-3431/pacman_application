import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pacman_application/database/game_user.dart';
import 'package:pacman_application/database/login.dart';
import 'package:pacman_application/database/session.dart';

class Appbar extends AppBar {
  Appbar({super.key, required this.context, this.header = const Text("")});

  final Text header;
  final BuildContext context;

  @override
  Widget? get title => Center(child: header);

  @override
  List<Widget>? get actions => [
    IconButton(
      onPressed: () {
        FirebaseAuth.instance.signOut();
        currentUser = GameUser(uid: "0");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (final BuildContext context) => Login()));
      },
      icon: Icon(Icons.logout, color: Colors.black,),
    ),
  ];

  @override
  double? get elevation => 8;

  @override
  ShapeBorder? get shape => RoundedRectangleBorder(
    side: BorderSide(width: 2),
    borderRadius: BorderRadiusGeometry.vertical(bottom: Radius.circular(16))
  );
}
