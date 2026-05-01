
import 'package:flutter/material.dart';
import 'package:pacman_application/constants.dart';
import 'package:pacman_application/utils/bonus_type.dart';
import 'package:pacman_application/screens/appbar.dart';
import 'package:pacman_application/screens/sidebar.dart';
import 'package:pacman_application/utils/bonus_card.dart';

class CollectablesScreen extends StatefulWidget {
  const CollectablesScreen({super.key});

  @override
  State<StatefulWidget> createState() => CollectablesScreenState();
}

class CollectablesScreenState extends State<CollectablesScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: Appbar(
      context: context,
      header: Text("COLLECTABLES", style: headerTextStyle),
    ),
    drawer: Sidebar(),
    body: SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Here is all the collectable you have got!",
              style: TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 20),

            GridView.builder(
              shrinkWrap: true,
              itemCount: BonusType.values.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, i) => BonusCard(i),
            ),
          ],
        ),
      ),
    ),
  );
}
