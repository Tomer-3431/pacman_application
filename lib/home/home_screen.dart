import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacman_application/database/session.dart';
import 'package:pacman_application/game/game_displayer.dart';
import 'package:pacman_application/home/appbar.dart';
import 'package:pacman_application/home/sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late Timer _startTimer;

  @override
  void initState() {
    super.initState();
    _startTimer = Timer(Duration(milliseconds: 400), () {
      print(currentUser.haveInitalized());
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _startTimer.cancel();
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
        header: Text("Home Screen", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: "Pacfont"),),
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
                  Text("Your High Score is ${currentUser.highScore},\ncongratulation", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                ],
              ),

              Spacer(),

              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GameDisplayer()));
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
                          color: Colors.amber[600],
                        ),
                        Text(
                          "Quick Play",
                          style: TextStyle(
                            fontSize: 30,
                            fontFamily: "PacFont",
                            color: Colors.amber[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Spacer(),
              Spacer(),
              Row(
                children: [
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
