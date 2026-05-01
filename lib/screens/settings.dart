import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pacman_application/constants.dart';
import 'package:pacman_application/database/session.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/utils/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  Color pickedColor = Colors.yellow;

  @override
  void initState() {
    super.initState();

    if (!isAnonymous) getColor();
  }

  void getColor() async {
    final prefs = await SharedPreferences.getInstance();

    final a = prefs.getInt("pacmanColor/a");
    final r = prefs.getInt("pacmanColor/r");
    final g = prefs.getInt("pacmanColor/g");
    final b = prefs.getInt("pacmanColor/b");

    if (a == null || r == null || g == null || b == null) {
      return;
    }

    pickedColor = Color.fromARGB(a, r, g, b);
  }

  int floatToInt8(double x) {
    return (x * 255.0).round().clamp(0, 255);
  }

  void saveColor() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setInt(
      "pacmanColor/a",
      floatToInt8(pickedColor.a),
    );
    prefs.setInt(
      "pacmanColor/r",
      floatToInt8(pickedColor.r),
    );
    prefs.setInt(
      "pacmanColor/g",
      floatToInt8(pickedColor.g),
    );
    prefs.setInt(
      "pacmanColor/b",
      floatToInt8(pickedColor.b),
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  void colorDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          height: (MediaQuery.of(context).size.height / 3).clamp(370, 600),
          child: HueRingPicker(
            pickerColor: pickedColor,
            onColorChanged: (Color color) {
              setState(() {
                pickedColor = color;
              });
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              saveColor();
              Navigator.of(context).pop();
            },
            child: const Text("Got it")
          )
        ],
      ),
    );
  }

  void resetPacmanColor() {
    pickedColor = pacmanColor;
    saveColor();
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: Appbar(
      context: context,
      header: Text(
        "SETTINGS SCREEN",
        style: headerTextStyle,
      ),
    ),
    drawer: Sidebar(),
    body: SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Center(
          child: Column(
            spacing: 40,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => colorDialog(context),
                style: Theme.of(context).menuButtonTheme.style,
                child: Text(
                  "select pacman color",
                  style: TextStyle(fontFamily: "PressStart"),
                ),
              ),

              ElevatedButton(
                onPressed: () => resetPacmanColor(),
                style: Theme.of(context).menuButtonTheme.style,
                child: Text(
                  "reset pacman color",
                  style: TextStyle(fontFamily: "PressStart"),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
