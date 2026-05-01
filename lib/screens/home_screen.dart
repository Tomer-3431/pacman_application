import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacman_application/constants.dart';
import 'package:pacman_application/database/session.dart';
import 'package:pacman_application/utils/bonus_type.dart';
import 'package:pacman_application/utils/game_displayer.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/utils/sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  double progress = 0;

  @override
  void initState() {
    super.initState();

    _getBonusProgress();
  }

  void _getBonusProgress() {
    int num = 0;
    for (MapEntry<BonusType, int> entry in currentUser.bonusTable.entries) {
      if (entry.value > 0) num++;
    }

    progress = num / currentUser.bonusTable.length;
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
    if (!currentUser.haveInitalized()) {
      setState(() {});
    }

    return Scaffold(
      appBar: Appbar(
        context: context,
        header: Text("HOME SCREEN", style: headerTextStyle),
      ),
      drawer: Sidebar(),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            spacing: 10,
            children: [
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 10,
                children: [
                  CircleAvatar(),
                  Text(
                    currentUser.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                spacing: 20,
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber[600], size: 80),
                  Text(
                    "Your high score\nis currently ${currentUser.highScore},\ncongratulation",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),

              Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                spacing: 20,
                children: [
                  Text(
                    "You have collected\n${progress * 100}% from all the\ncollectables",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),

                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CircularProgressIndicator(
                        value: progress,
                        color: Colors.blue[900],
                        strokeWidth: 10,
                      ),
                    ),
                  ),
                ],
              ),

              Spacer(),

              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => GameDisplayer()),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: BoxBorder.all(color: Colors.black, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 10,
                      children: [
                        Icon(
                          Icons.videogame_asset,
                          size: 35,
                          color: Theme.of(context).primaryColor,
                        ),
                        Text(
                          "QUICK PLAY",
                          style: TextStyle(
                            fontSize: 28,
                            fontFamily: "PacFont",
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
