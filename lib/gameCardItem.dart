import 'dart:developer' as developer;

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';

class GameCardItem extends StatefulWidget {
  final Image cardImage;
  final int animationOrder;

  GameCardItem(this.cardImage, this.animationOrder);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<GameCardItem>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;
  int beginAnimation = 0;
  final _assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    beginAnimation += (widget.animationOrder + 1) * 400;
    developer.log('begin animation ' + beginAnimation.toString());

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      end: Offset.zero,
      begin: const Offset(0.0, 1.2),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    reset();
  }

  Future reset() async {
    _controller.reset();
    return Future.delayed(
      Duration(milliseconds: beginAnimation),
      () => animate(),
    );
  }


  animate() async{
    _assetsAudioPlayer.open(Audio("assets/suck.wav"));
     await _controller.forward();
  }

  @override
  void didUpdateWidget(covariant GameCardItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // maybe I shouldn't have to do that
    if (oldWidget.cardImage != widget.cardImage) {
      setState(() {
        reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Card(
        elevation: 5,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0), child: widget.cardImage),
      ),
    );
  }
}
