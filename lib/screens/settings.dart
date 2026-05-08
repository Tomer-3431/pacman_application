import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:pacman_application/utils/constants.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/utils/sidebar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Allows the player to customise the colours of Pac-Man, each ghost, and
/// the maze walls.
///
/// Each element has its own colour picker (a [HueRingPicker] shown in an
/// [AlertDialog]) and a reset button that restores the game's original colour.
/// A global "Reset Settings" button at the bottom reverts every element at
/// once. Colour choices are persisted via [SharedPreferences] so they survive
/// app restarts.
class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  // ── Fields ───────────────────────────────────────────────────────────────

  /// Currently selected colour for Pac-Man.
  Color _pacmanColor = pacmanColor;

  /// Currently selected colour for Blinky (red ghost).
  Color _blinkyColor = blinkyColor;

  /// Currently selected colour for Pinky (pink ghost).
  Color _pinkyColor = pinkyColor;

  /// Currently selected colour for Inky (cyan ghost).
  Color _inkyColor = inkyColor;

  /// Currently selected colour for Clyde (orange ghost).
  Color _clydeColor = clydeColor;

  /// Currently selected colour for the maze walls.
  Color _mapColor = mapColor;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadColors();
  }

  @override
  void dispose() {
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
      header: Text('SETTINGS', style: headerTextStyle),
    ),
    drawer: const Sidebar(),
    body: SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Center(
          child: Column(
            spacing: 40,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Here you can change the colors\nof the game elements',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              const Spacer(),

              _colorPickerRow('pacman'),
              _colorPickerRow('blinky'),
              _colorPickerRow('pinky'),
              _colorPickerRow('inky'),
              _colorPickerRow('clyde'),
              _colorPickerRow('map'),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _resetPacmanColor();
                        _resetBlinkyColor();
                        _resetPinkyColor();
                        _resetInkyColor();
                        _resetClydeColor();
                        _resetMapColor();
                      });
                    },
                    child: const Text(
                      'Reset Settings',
                      style: TextStyle(
                        fontFamily: 'PressStart',
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // ── Private helpers ──────────────────────────────────────────────────────

  /// Loads all persisted colour preferences from [SharedPreferences] and
  /// updates the corresponding state fields, triggering a rebuild.
  void _loadColors() async {
    final prefs = await SharedPreferences.getInstance();

    Color? loaded;

    loaded = _readColorPrefs(prefs, 'pacman');
    if (loaded != null) _pacmanColor = loaded;

    loaded = _readColorPrefs(prefs, 'blinky');
    if (loaded != null) _blinkyColor = loaded;

    loaded = _readColorPrefs(prefs, 'pinky');
    if (loaded != null) _pinkyColor = loaded;

    loaded = _readColorPrefs(prefs, 'inky');
    if (loaded != null) _inkyColor = loaded;

    loaded = _readColorPrefs(prefs, 'clyde');
    if (loaded != null) _clydeColor = loaded;

    loaded = _readColorPrefs(prefs, 'map');
    if (loaded != null) _mapColor = loaded;

    setState(() {});
  }

  /// Reads the ARGB components for [character] from [prefs] and returns the
  /// reconstructed [Color], or `null` if any component is missing.
  Color? _readColorPrefs(SharedPreferences prefs, String character) {
    final a = prefs.getInt('${character}Color/a');
    final r = prefs.getInt('${character}Color/r');
    final g = prefs.getInt('${character}Color/g');
    final b = prefs.getInt('${character}Color/b');
    if (a == null || r == null || g == null || b == null) return null;
    return Color.fromARGB(a, r, g, b);
  }

  /// Converts a double colour channel value in [0, 1] to an 8-bit integer
  /// in [0, 255].
  int _floatToInt8(double x) => (x * 255.0).round().clamp(0, 255);

  /// Returns the currently selected [Color] for [character].
  Color _getCharacterColor(String character) {
    return switch (character) {
      'pacman' => _pacmanColor,
      'blinky' => _blinkyColor,
      'pinky'  => _pinkyColor,
      'inky'   => _inkyColor,
      'clyde'  => _clydeColor,
      'map'    => _mapColor,
      _        => Colors.transparent,
    };
  }

  /// Persists the current colour for [character] to [SharedPreferences].
  void _saveColor(String character) async {
    final prefs = await SharedPreferences.getInstance();
    final color = _getCharacterColor(character);

    await prefs.setInt('${character}Color/a', _floatToInt8(color.a));
    await prefs.setInt('${character}Color/r', _floatToInt8(color.r));
    await prefs.setInt('${character}Color/g', _floatToInt8(color.g));
    await prefs.setInt('${character}Color/b', _floatToInt8(color.b));
  }

  /// Opens a colour-picker dialog for [character]. The selected colour is
  /// applied in real time and saved when the user confirms.
  void _showColorDialog(BuildContext context, String character) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(
          child: Text(
            'Change ${character[0].toUpperCase()}${character.substring(1)} color',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        content: SizedBox(
          height: (MediaQuery.of(context).size.height / 3).clamp(370, 600),
          child: HueRingPicker(
            pickerColor: _getCharacterColor(character),
            onColorChanged: (Color color) {
              setState(() {
                switch (character) {
                  case 'pacman': _pacmanColor = color;
                  case 'blinky': _blinkyColor = color;
                  case 'pinky':  _pinkyColor  = color;
                  case 'inky':   _inkyColor   = color;
                  case 'clyde':  _clydeColor  = color;
                  case 'map':    _mapColor    = color;
                }
              });
            },
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _saveColor(character);
              Navigator.of(context).pop();
            },
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  // ── Reset helpers ────────────────────────────────────────────────────────

  void _resetPacmanColor() { _pacmanColor = pacmanColor; _saveColor('pacman'); }
  void _resetBlinkyColor() { _blinkyColor = blinkyColor; _saveColor('blinky'); }
  void _resetPinkyColor()  { _pinkyColor  = pinkyColor;  _saveColor('pinky'); }
  void _resetInkyColor()   { _inkyColor   = inkyColor;   _saveColor('inky'); }
  void _resetClydeColor()  { _clydeColor  = clydeColor;  _saveColor('clyde'); }
  void _resetMapColor()    { _mapColor    = mapColor;     _saveColor('map'); }

  /// Resets the colour of [character] to its default value and saves it.
  void _resetColor(String character) {
    setState(() {
      switch (character) {
        case 'pacman': _resetPacmanColor();
        case 'blinky': _resetBlinkyColor();
        case 'pinky':  _resetPinkyColor();
        case 'inky':   _resetInkyColor();
        case 'clyde':  _resetClydeColor();
        case 'map':    _resetMapColor();
      }
    });
  }

  // ── Widget builders ──────────────────────────────────────────────────────

  /// Builds a row containing a colour-picker button (labelled with
  /// [character]'s name in its current colour) and a reset icon button.
  Widget _colorPickerRow(String character) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,
      children: [
        ElevatedButton(
          onPressed: () => _showColorDialog(context, character),
          child: Text(
            '${character[0].toUpperCase()}${character.substring(1)} Color',
            style: TextStyle(
              fontFamily: 'PressStart',
              color: _getCharacterColor(character),
            ),
          ),
        ),
        IconButton(
          onPressed: () => _resetColor(character),
          icon: const Icon(Icons.restore_rounded),
        ),
      ],
    );
  }
}