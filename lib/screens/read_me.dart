import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacman_application/utils/constants.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/utils/sidebar.dart';

class ReadMe extends StatefulWidget {
  const ReadMe({super.key});

  @override
  State<ReadMe> createState() => ReadMeState();
}

class ReadMeState extends State<ReadMe> {
  @override
  void dispose() {
    super.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: Appbar(
      context: context,
      header: Text(
        "READ ME",
        style: headerTextStyle,
      ),
    ),
    drawer: Sidebar(),
    body: SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Center(child: Text("PLACEHOLDER for Read Me")),
      ),
    ),
  );
}
