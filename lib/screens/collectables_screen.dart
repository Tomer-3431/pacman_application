import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pacman_application/utils/constants.dart';
import 'package:pacman_application/utils/bonus_type.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/utils/sidebar.dart';
import 'package:pacman_application/utils/bonus_card.dart';

/// Displays the player's full collectable item collection in a 2-column grid.
///
/// Each grid cell is rendered by a [BonusCard] widget. Cards for items the
/// player has not yet obtained are shown in greyscale with a strikethrough
/// label; collected items are shown in full colour and open a detail dialog
/// on tap.
class CollectablesScreen extends StatefulWidget {
  const CollectablesScreen({super.key});

  @override
  State<CollectablesScreen> createState() => CollectablesScreenState();
}

class CollectablesScreenState extends State<CollectablesScreen> {
  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    // Restore portrait orientation when leaving the screen.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: Appbar(
      context: context,
      header: Text('COLLECTABLES', style: headerTextStyle),
    ),
    drawer: const Sidebar(),
    body: SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Here is all the collectables you have got!',
              style: TextStyle(fontSize: 20, color: Colors.black),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // 2-column grid of one BonusCard per BonusType.
            GridView.builder(
              shrinkWrap: true,
              itemCount: BonusType.values.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (_, i) => BonusCard(i),
            ),
          ],
        ),
      ),
    ),
  );
}