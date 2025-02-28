import 'dart:developer' as developer;

import 'package:audioplayers/audioplayers.dart';
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

class _MyAppState extends State<GameCardItem> with TickerProviderStateMixin {
  late AnimationController _controllerSlide;
  late Animation<Offset> _slideInAnimation;
  int beginAnimation = 0;
  final _assetsAudioPlayer  = AudioPlayer();
  Offset _begin = Offset(0.0, 1.2);

  @override
  void dispose() {
    _controllerSlide.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    beginAnimation += (widget.animationOrder + 1) * 400;
    developer.log('begin animation ' + beginAnimation.toString());

    _controllerSlide = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    reset();
  }

  reset() {
    _controllerSlide.reset();
    _begin = Offset(0.0, 1.2);
    _slideInAnimation = Tween<Offset>(
      end: Offset.zero,
      begin: _begin,
    ).animate(
        CurvedAnimation(parent: _controllerSlide, curve: Curves.elasticOut));

    // every card gets an increased delay, so the appear one by one
    Future.delayed(
      Duration(milliseconds: beginAnimation),
      () => _playAnimation(),
    );
  }

  _playAnimation() async {
    // first slide in, then let the card hover
    developer.log(widget.cardImage.image.toString());
    _assetsAudioPlayer.play(AssetSource('suck.wav'));
    await _controllerSlide.forward().whenComplete(() => _hover());
  }

  _hover() {
    setState(() {
      _begin = Offset(0.0, 0.05);
      _slideInAnimation = Tween<Offset>(
        end: Offset.zero,
        begin: _begin,
      ).animate(CurvedAnimation(parent: _controllerSlide, curve: Curves.ease));
      _controllerSlide.repeat(reverse: true).orCancel;
    });
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
      position: _slideInAnimation,
      child: SizedBox(
        width: (MediaQuery.of(context).size.width / 3) - 4,
        child: Card(
          elevation: 8,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: widget.cardImage),
        ),
      ),
    );
  }
}
