import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacman_application/constants.dart';
import 'package:pacman_application/screens/appbar.dart';
import 'package:pacman_application/screens/sidebar.dart';

class Credit extends StatefulWidget {
  const Credit({super.key});

  @override
  State<StatefulWidget> createState() => CreditState();
}

class CreditState extends State<Credit> {
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
        "CREDIT SCREEN",
        style: headerTextStyle,
      ),
    ),
    drawer: Sidebar(),
    body: SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Center(child: Text("PLACEHOLDER for credits")),
      ),
    ),
  );
}
