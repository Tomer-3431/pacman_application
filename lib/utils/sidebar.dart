import 'package:flutter/material.dart';
import 'package:pacman_application/database/session.dart';
import 'package:pacman_application/screens/credit.dart';
import 'package:pacman_application/screens/collectables_screen.dart';
import 'package:pacman_application/utils/game_displayer.dart';
import 'package:pacman_application/screens/home_screen.dart';
import 'package:pacman_application/screens/leaderboard.dart';
import 'package:pacman_application/screens/rules.dart';
import 'package:pacman_application/screens/settings.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<StatefulWidget> createState() => SidebarState();
}

class SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) => Drawer(
    child: Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 50,
        children: [
          SizedBox(height: 30),
          Text('Welcome ${currentUser.name}!', style: TextStyle(fontSize: 26)),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (final BuildContext context) => HomeScreen()
                ),
              );
            },
            child: Row(
              spacing: 5,
              children: [
                Icon(Icons.home),
                Text("Home"),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Icon(Icons.arrow_forward_ios)],
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (final BuildContext context) => GameDisplayer(),
                ),
              );
            },
            child: Row(
              spacing: 5,
              children: [
                Icon(Icons.videogame_asset),
                Text("Play a Game"),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Icon(Icons.arrow_forward_ios)],
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (final BuildContext context) => Rules(),
                ),
              );
            },
            child: Row(
              spacing: 5,
              children: [
                Icon(Icons.rule_sharp),
                Text("Read the Rules"),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Icon(Icons.arrow_forward_ios)],
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (final BuildContext context) => Credit(),
                ),
              );
            },
            child: Row(
              spacing: 5,
              children: [
                Icon(Icons.favorite_rounded),
                Text("Explore the Credits"),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Icon(Icons.arrow_forward_ios)],
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (final BuildContext context) => Leaderboard(),
                ),
              );
            },
            child: Row(
              spacing: 5,
              children: [
                Icon(Icons.leaderboard),
                Text("See the Leaderboard"),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Icon(Icons.arrow_forward_ios)],
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (final BuildContext context) => CollectablesScreen(),
                ),
              );
            },
            child: Row(
              spacing: 5,
              children: [
                Icon(Icons.grid_view),
                Text("Get the Collectable"),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Icon(Icons.arrow_forward_ios)],
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (final BuildContext context) => Settings(),
                ),
              );
            },
            child: Row(
              spacing: 5,
              children: [
                Icon(Icons.settings),
                Text("Change the Settings"),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [Icon(Icons.arrow_forward_ios)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
