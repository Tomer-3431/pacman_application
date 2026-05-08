import 'package:flutter/material.dart';
import 'package:pacman_application/database/session.dart';
import 'package:pacman_application/screens/read_me.dart';
import 'package:pacman_application/screens/collectables_screen.dart';
import 'package:pacman_application/utils/game_displayer.dart';
import 'package:pacman_application/screens/home_screen.dart';
import 'package:pacman_application/screens/leaderboard_screen.dart';
import 'package:pacman_application/screens/settings.dart';

/// A navigation [Drawer] shown when the user swipes from the left edge or
/// taps the hamburger icon in any screen's [Appbar].
///
/// Displays the current user's name at the top, followed by tappable rows
/// that navigate (via `pushReplacement`) to each major section of the app:
/// Home, Play, Read Me, Leaderboard, Collectables, and Settings.
class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => SidebarState();
}

class SidebarState extends State<Sidebar> {
  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => Drawer(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 50,
        children: [
          const SizedBox(height: 30),

          // ── Header ──────────────────────────────────────────────────────
          Text(
            'Welcome ${currentUser.name}!',
            style: const TextStyle(fontSize: 26),
          ),

          // ── Home ─────────────────────────────────────────────────────────
          _navRow(
            context,
            icon: Icons.home,
            label: 'Home',
            destination: const HomeScreen(),
          ),

          // ── Play ─────────────────────────────────────────────────────────
          _navRow(
            context,
            icon: Icons.videogame_asset,
            label: 'Play a Game',
            destination: const GameDisplayer(),
          ),

          // ── Read Me ──────────────────────────────────────────────────────
          _navRow(
            context,
            icon: Icons.favorite_rounded,
            label: 'Read Me',
            destination: const ReadMe(),
          ),

          // ── Leaderboard ──────────────────────────────────────────────────
          _navRow(
            context,
            icon: Icons.leaderboard,
            label: 'Leaderboard',
            destination: const LeaderboardScreen(),
          ),

          // ── Collectables ─────────────────────────────────────────────────
          _navRow(
            context,
            icon: Icons.grid_view,
            label: 'Collectables',
            destination: const CollectablesScreen(),
          ),

          // ── Settings ─────────────────────────────────────────────────────
          _navRow(
            context,
            icon: Icons.settings,
            label: 'Settings',
            destination: const Settings(),
          ),
        ],
      ),
    ),
  );

  // ── Private helpers ──────────────────────────────────────────────────────

  /// Builds a single navigation row with an [icon], a [label], and a
  /// right-pointing chevron. Tapping the row replaces the current route
  /// with [destination].
  Widget _navRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget destination,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => destination),
      ),
      child: Row(
        spacing: 5,
        children: [
          Icon(icon),
          Text(label),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [Icon(Icons.arrow_forward_ios)],
            ),
          ),
        ],
      ),
    );
  }
}