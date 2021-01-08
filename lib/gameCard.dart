import 'dart:math';

import 'package:flutter/material.dart';

import 'flags.dart';

class GameCard extends StatefulWidget {
  final Image elementAt;

  GameCard(this.elementAt);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<GameCard> {
  // Define the various properties with default values. Update these properties
  // when the user taps a FloatingActionButton.

  double _width = 50;
  double _height = 50;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  runAnimation(){
    setState(() {
      final random = Random();

      // Generate a random width and height.
      _width = random.nextInt(300).toDouble();
      _height = random.nextInt(300).toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    // runAnimation();
    return AnimatedContainer(
      //width: _width,
      //height: _height,
      // Use the properties stored in the State class.
      // Define how long the animation should take.
      duration: Duration(seconds: 1),
      // Provide an optional curve to make the animation feel smoother.
      curve: Curves.fastOutSlowIn,
      child: Card(
        elevation: 5,
        child: widget.elementAt,
      ),
    );
  }
}
