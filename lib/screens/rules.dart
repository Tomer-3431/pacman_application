import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacman_application/constants.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/utils/sidebar.dart';

class Rules extends StatefulWidget {
  const Rules({super.key});

  @override
  State<StatefulWidget> createState() => RulesState();
}

class RulesState extends State<Rules> {
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
        "RULES SCREEN",
        style: headerTextStyle,
      ),
    ),
    drawer: Sidebar(),
    body: SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Center(child: Text("PLACEHOLDER for rules")),
      ),
    ),
  );
}
