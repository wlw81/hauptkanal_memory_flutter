import 'dart:math';

import 'package:flutter/material.dart';

import 'flags.dart';

class GameCard extends StatefulWidget {
  final Image cardImage;

  GameCard(this.cardImage);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<GameCard>  with SingleTickerProviderStateMixin{
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();
    _offsetAnimation = Tween<Offset>(
      end: Offset.zero,
      begin: const Offset(0, 1.5),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticIn,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
        position: _offsetAnimation,
          child: Card(
            elevation: 5,
            child: widget.cardImage,
          ),
          );
  }
}
