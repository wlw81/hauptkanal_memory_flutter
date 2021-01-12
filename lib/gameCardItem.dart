import 'dart:io';
import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

import 'flags.dart';

class GameCardItem extends StatefulWidget {

  Image cardImage;
  int animationOrder;

  GameCardItem(this.cardImage, this.animationOrder);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }

}

class _MyAppState extends State<GameCardItem> with SingleTickerProviderStateMixin {

  AnimationController _controller;
  Animation<Offset> _offsetAnimation;
  int beginAnimation = 0;
  final assetsAudioPlayer = AssetsAudioPlayer();
  Image _cardImage;

  @override
  void setState(fn) {
    super.setState(fn);
    developer.log('SET STATEEEEEE!!!!!');
    delay();
  }

  @override
  void initState() {
    super.initState();

    beginAnimation += (widget.animationOrder+1) * 400;
    developer.log('begin animation '+ beginAnimation.toString());
    assetsAudioPlayer.open(Audio("assets/suck.wav"));

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      end: Offset.zero,
      begin: const Offset(0.0, 1.2),
    ).animate(CurvedAnimation(
      parent: _controller,
       curve: Curves.elasticOut)
    );

    delay();
  }


  delay(){
    _controller.reset();
    Future _calculation = Future.delayed(
      Duration(milliseconds: beginAnimation),
          () =>    animate()
      ,
    );
  }

  animate() async{
    assetsAudioPlayer.play().then((value) => _controller.forward());
  }

  @override
  Widget build(BuildContext context) {

    // I shouldn't have to do that
    if(_cardImage != widget.cardImage){
      setState(() { _cardImage = widget.cardImage;});
    }

    return SlideTransition(
      position: _offsetAnimation,
      child: Card(
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        elevation: 5,
        child: _cardImage,
      ),
    );
  }

}