import 'package:pacman_application/database/game_user.dart';

/// The [GameUser] object for the player who is currently logged in.
///
/// Initialised to the anonymous guest (uid `"0"`) at app start-up and
/// replaced once a successful sign-in completes in [Login] or [Signup].
/// All screens read from this global rather than passing the user down the
/// widget tree, keeping the session state centrally accessible.
GameUser currentUser = GameUser(uid: '0');

/// Whether the current session is a guest (unauthenticated) session.
///
/// Set to `true` when the user taps "Enter as a guest" on the [Login]
/// screen, and `false` after any successful Firebase sign-in. Screens and
/// game logic gate score-saving and collectable-saving behaviour behind
/// this flag.
bool isAnonymous = true;