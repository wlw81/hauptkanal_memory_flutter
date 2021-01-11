import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'flags.dart';

class GameCard extends StatefulWidget {
  final Image cardImage;
  final TickerProvider tickerProvider;
  final int animationOrderIndex;

  GameCard(this.tickerProvider, this.animationOrderIndex, this.cardImage);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<GameCard> {
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;
  Image lastImage;
  double beginAnimation = 0.0;

  @override
  void initState() {
    super.initState();

    lastImage = widget.cardImage;

    if(widget.animationOrderIndex == Flags.ORDER_SECOND_ANIMATION){
      beginAnimation = 0.2;
    }if ( widget.animationOrderIndex == Flags.ORDER_THIRD_ANIMATION){
      beginAnimation = 0.3;
    }else if ( widget.animationOrderIndex == Flags.ORDER_FIRST_ANIMATION){
      beginAnimation = 0.1;
    }else{
      developer.log('Other: ' + widget.animationOrderIndex.toString());
    }

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: widget.tickerProvider,
    )..forward(from: beginAnimation);
    _offsetAnimation = Tween<Offset>(
      end: Offset.zero,
      begin: const Offset(0.0, 0.5),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(lastImage != widget.cardImage){
      _controller.reset();
      _controller.forward(from: beginAnimation);
      lastImage = widget.cardImage;
    }

    return SlideTransition(
        position: _offsetAnimation,
          child: Card(
            elevation: 5,
            child: widget.cardImage,
          ),
          );
  }
}
