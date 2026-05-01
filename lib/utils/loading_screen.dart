import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pacman_application/utils/appbar.dart';
import 'package:pacman_application/screens/home_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});


  @override
  State<StatefulWidget> createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(Duration(milliseconds: 500), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: Appbar(context: context),
    body: Center(
      child: Text("Loading...."),
    ),
  );
  
}