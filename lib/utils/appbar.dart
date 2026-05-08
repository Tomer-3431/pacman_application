import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pacman_application/database/game_user.dart';
import 'package:pacman_application/screens/login.dart';
import 'package:pacman_application/database/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A custom [AppBar] used on every screen in the application.
///
/// Renders a centred [header] title and, when [canLogout] is `true`,
/// a logout icon button that signs the user out of Firebase, clears the
/// stored session preferences, resets [currentUser] to the anonymous
/// placeholder, and navigates back to [Login].
class Appbar extends AppBar {
  // ── Constructor ─────────────────────────────────────────────────────────

  /// Creates an [Appbar].
  ///
  /// - [context] – the [BuildContext] used for navigation on logout.
  /// - [header]  – the title widget displayed in the centre of the bar.
  /// - [canLogout] – when `false` the logout button is hidden (useful on
  ///   the [Login] and [Signup] screens).
  Appbar({
    super.key,
    required this.context,
    this.header = const Text(''),
    this.canLogout = true,
  });

  // ── Fields ───────────────────────────────────────────────────────────────

  /// The [BuildContext] used when navigating to [Login] after sign-out.
  final BuildContext context;

  /// The widget rendered as the centred app-bar title.
  final Text header;

  /// Controls visibility of the logout icon button.
  ///
  /// Set to `false` on screens where the user is not yet authenticated
  /// (e.g. [Login], [Signup]).
  final bool canLogout;

  // ── AppBar overrides ────────────────────────────────────────────────────

  @override
  Widget? get title => Center(child: header);

  @override
  List<Widget>? get actions => canLogout
      ? [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
              currentUser = GameUser(uid: '0');
              _clearPrefs();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (final BuildContext context) => Login(),
                ),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.black),
          ),
        ]
      : [];

  @override
  double? get elevation => 8;

  @override
  ShapeBorder? get shape => const RoundedRectangleBorder(
    side: BorderSide(width: 2),
    borderRadius: BorderRadiusGeometry.vertical(bottom: Radius.circular(16)),
  );

  // ── Private methods ─────────────────────────────────────────────────────

  /// Removes the persisted "last user" keys from [SharedPreferences] so the
  /// app does not auto-login on next launch.
  void _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lastUser/uid');
    await prefs.remove('lastUser/name');
    await prefs.remove('lastUser/highScore');
    await prefs.remove('lastUser/email');
  }
}