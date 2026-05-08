import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pacman_application/utils/constants.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/utils/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  Color pacmanPickedColor = pacmanColor;
  Color blinkyPickedColor = blinkyColor;
  Color pinkyPickedColor = pinkyColor;
  Color inkyPickedColor = inkyColor;
  Color clydePickedColor = clydeColor;
  Color mapPickedColor = mapColor;

  @override
  void initState() {
    super.initState();

    getColor();
  }

  void getColor() async {
    final prefs = await SharedPreferences.getInstance();

    var a = prefs.getInt("pacmanColor/a");
    var r = prefs.getInt("pacmanColor/r");
    var g = prefs.getInt("pacmanColor/g");
    var b = prefs.getInt("pacmanColor/b");
    if (a == null || r == null || g == null || b == null) {
      return;
    }
    pacmanPickedColor = Color.fromARGB(a, r, g, b);

    a = prefs.getInt("blinkyColor/a");
    r = prefs.getInt("blinkyColor/r");
    g = prefs.getInt("blinkyColor/g");
    b = prefs.getInt("blinkyColor/b");

    if (a == null || r == null || g == null || b == null) {
      return;
    }
    blinkyPickedColor = Color.fromARGB(a, r, g, b);

    a = prefs.getInt("pinkyColor/a");
    r = prefs.getInt("pinkyColor/r");
    g = prefs.getInt("pinkyColor/g");
    b = prefs.getInt("pinkyColor/b");

    if (a == null || r == null || g == null || b == null) {
      return;
    }
    pinkyPickedColor = Color.fromARGB(a, r, g, b);

    a = prefs.getInt("inkyColor/a");
    r = prefs.getInt("inkyColor/r");
    g = prefs.getInt("inkyColor/g");
    b = prefs.getInt("inkyColor/b");

    if (a == null || r == null || g == null || b == null) {
      return;
    }
    inkyPickedColor = Color.fromARGB(a, r, g, b);

    a = prefs.getInt("clydeColor/a");
    r = prefs.getInt("clydeColor/r");
    g = prefs.getInt("clydeColor/g");
    b = prefs.getInt("clydeColor/b");

    if (a == null || r == null || g == null || b == null) {
      return;
    }
    clydePickedColor = Color.fromARGB(a, r, g, b);

    a = prefs.getInt("mapColor/a");
    r = prefs.getInt("mapColor/r");
    g = prefs.getInt("mapColor/g");
    b = prefs.getInt("mapColor/b");

    if (a == null || r == null || g == null || b == null) {
      return;
    }
    mapPickedColor = Color.fromARGB(a, r, g, b);

    setState(() {});
  }

  int floatToInt8(double x) {
    return (x * 255.0).round().clamp(0, 255);
  }

  Color getChracterColor(String character) {
    return switch (character) {
      "pacman" => pacmanPickedColor,
      "blinky" => blinkyPickedColor,
      "pinky" => pinkyPickedColor,
      "inky" => inkyPickedColor,
      "clyde" => clydePickedColor,
      "map" => mapPickedColor,
      _ => Colors.transparent,
    };
  }

  void saveColor(String character) async {
    final prefs = await SharedPreferences.getInstance();
    final color = getChracterColor(character);

    prefs.setInt("${character}Color/a", floatToInt8(color.a));
    prefs.setInt("${character}Color/r", floatToInt8(color.r));
    prefs.setInt("${character}Color/g", floatToInt8(color.g));
    prefs.setInt("${character}Color/b", floatToInt8(color.b));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    super.dispose();
  }

  void colorDialog(BuildContext context, String character) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(
          child: Text(
            "Change ${character[0].toUpperCase()}${character.substring(1)} color",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        content: SizedBox(
          height: (MediaQuery.of(context).size.height / 3).clamp(370, 600),
          child: HueRingPicker(
            pickerColor: getChracterColor(character),
            onColorChanged: (Color color) {
              setState(() {
                switch (character) {
                  case "pacman":
                    pacmanPickedColor = color;
                    break;
                  case "blinky":
                    blinkyPickedColor = color;
                    break;
                  case "pinky":
                    pinkyPickedColor = color;
                    break;
                  case "inky":
                    inkyPickedColor = color;
                    break;
                  case "clyde":
                    clydePickedColor = color;
                    break;
                  case "map":
                    mapPickedColor = color;
                    break;
                }
              });
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              saveColor(character);
              Navigator.of(context).pop();
            },
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }

  void resetPacmanColor() {
    pacmanPickedColor = pacmanColor;
    saveColor("pacman");
  }

  void resetBlinkyColor() {
    blinkyPickedColor = blinkyColor;
    saveColor("blinky");
  }

  void resetPinkyColor() {
    pinkyPickedColor = pinkyColor;
    saveColor("pinky");
  }

  void resetInkyColor() {
    inkyPickedColor = inkyColor;
    saveColor("inky");
  }

  void resetClydeColor() {
    clydePickedColor = clydeColor;
    saveColor("clyde");
  }

  void resetMapColor() {
    mapPickedColor = mapColor;
    saveColor("map");
  }

  void resetColor(String character) {
    switch (character) {
      case "pacman":
        resetPacmanColor();
        break;
      case "blinky":
        resetBlinkyColor();
        break;
      case "pinky":
        resetPinkyColor();
        break;
      case "inky":
        resetInkyColor();
        break;
      case "clyde":
        resetClydeColor();
        break;
      case "map":
        resetMapColor();
        break;
    }
  }

  Widget pickedColorWidget(String character) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,
      children: [
        ElevatedButton(
          onPressed: () => colorDialog(context, character),
          child: Text(
            "${character[0].toUpperCase()}${character.substring(1)} Color",
            style: TextStyle(
              fontFamily: "PressStart",
              color: getChracterColor(character),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              resetColor(character);
            });
          },
          icon: Icon(Icons.restore_rounded),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: Appbar(
      context: context,
      header: Text("SETTINGS", style: headerTextStyle),
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
              // Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Here you can change the colors\nof the game elements",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Spacer(),

              pickedColorWidget("pacman"),
              pickedColorWidget("blinky"),
              pickedColorWidget("pinky"),
              pickedColorWidget("inky"),
              pickedColorWidget("clyde"),
              pickedColorWidget("map"),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        resetPacmanColor();
                        resetBlinkyColor();
                        resetPinkyColor();
                        resetInkyColor();
                        resetClydeColor();
                        resetMapColor();
                      });
                    },
                    child: Text(
                      "Reset Settings",
                      style: TextStyle(
                        fontFamily: "PressStart",
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              // Spacer(),
            ],
          ),
        ),
      ),
    ),
  );
}
