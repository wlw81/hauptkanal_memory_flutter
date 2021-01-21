import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:hauptkanal_memory/cardSelector.dart';
import 'package:hauptkanal_memory/countdown.dart';
import 'package:hauptkanal_memory/score.dart';
import "package:intl/intl.dart";
import 'package:path_provider/path_provider.dart';

import 'flags.dart';

class Game extends StatefulWidget {
  final String currentStreet;
  final Function(int) onScoreChange;
  final List<String> streetImageNames;

  Game(this.currentStreet, this.onScoreChange, this.streetImageNames);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<Game> with TickerProviderStateMixin {
  final assetsAudioPlayer = AssetsAudioPlayer();
  List<FileSystemEntity> imageNames;
  int currentNumber = 0;
  int lastRandomNumber;
  int score = 0;
  Map<int, Image> _nextRandomImages;
  int secondsRemaining = Flags.COUNTDOWN_IN_SECONDS;
  AnimationController _controller;
  Animation<Offset> _offsetAnimation;
  Timer _timer;

  @override
  void initState() {
    super.initState();

    if (_timer == null || !_timer.isActive) {
      startTimer();
    }

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 0.01),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void dispose() {
    try {
      developer.log('Final score ' + score.toString());
      _timer.cancel();
      _controller.dispose();
    } finally {
      super.dispose();
    }
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (secondsRemaining == 0) {
          setState(() {
            try {
              timer.cancel();
            } finally {
              close(); // out of time
            }
          });
        } else {
          setState(() {
            secondsRemaining--;
          });
        }
      },
    );
  }

  close() {
    Navigator.pop(context);
  }

  int _generateHouseNumber() {
    int houseNumberGenerated = currentNumber;
    while (houseNumberGenerated == currentNumber ||
        houseNumberGenerated == (currentNumber + 1) ||
        houseNumberGenerated == lastRandomNumber) {
      houseNumberGenerated = Random.secure().nextInt(widget.streetImageNames.length);
    }
    lastRandomNumber = houseNumberGenerated;
    return houseNumberGenerated;
  }

  playFlickAudio() async {
    assetsAudioPlayer.open(Audio("assets/flick.wav"));
  }

  playWrongAudio() async {
    assetsAudioPlayer.open(Audio("assets/bad.mp3"));
  }

  _cardTapped(int pSelectedIndex) {
    developer.log('Confirmed card tapped: ' + pSelectedIndex.toString());
    if (pSelectedIndex > -1 && _nextRandomImages.isNotEmpty) {
      _controller.forward(from: 0.0);

      // check tomorrow is this really works
      if (_nextRandomImages.keys.elementAt(pSelectedIndex) == (currentNumber +1)) {
        playFlickAudio();
        preCacheNextImage();

        setState(() {
          _nextRandomImages.clear();
          int additionalScore = 10 * secondsRemaining;
          score += additionalScore;
          currentNumber++;
        });

        if (currentNumber >= (widget.streetImageNames.length - 2)) {
          close(); // game completed!
        }
      } else {
        playWrongAudio();
        setState(() {
          score -= 500;
        });
      }
      widget.onScoreChange(score);
      developer.log('Current score: ' + score.toString());
    }
  }

  Map<int, Image> _generateRandomCardImages() {
    if (_nextRandomImages == null || _nextRandomImages.isEmpty) {
      // putting into hashmap, to achieve random order
      HashMap newRandomImagesUnsorted = new HashMap<int, Image>();
      for (int i = 0; i < Flags.RANDOM_CARD_COUNT - 1; i++) {
        int number = _generateHouseNumber();
        newRandomImagesUnsorted.putIfAbsent(number, () => Image.asset(widget.streetImageNames.elementAt(number)));
      }
      newRandomImagesUnsorted.putIfAbsent(currentNumber+1, () => Image.asset(widget.streetImageNames.elementAt(currentNumber +1)));
      _nextRandomImages = Map.from(newRandomImagesUnsorted);
    }
    return _nextRandomImages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
              height: double.infinity,
              width: double.infinity,
              child:
              Image.asset(widget.streetImageNames.elementAt(currentNumber), fit: BoxFit.cover),
              ),
          Center(child: Countdown(secondsRemaining)),
          SlideTransition(
              position: _offsetAnimation, child: Score(score, true)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Expanded(
                child: SizedBox(
                    height: 200,
                    child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 20.5, left: 2.5, right: 2.5, top: 20.0),
                        child: CardSelector(
                            _generateRandomCardImages().values.toList(), _cardTapped)))),
          ])
        ],
      ),
    );
  }

  void preCacheNextImage() async {
    try {
      for (int i = 0; i < Flags.RANDOM_CARD_COUNT; i++) {
        int renderNumber = currentNumber + i;
        if (renderNumber < widget.streetImageNames.length) {
          precacheImage(
              Image.asset(widget.streetImageNames.elementAt(renderNumber)).image,
              context);
        }
      }
    } catch (Exception) {
      developer.log('Failed to pre cache: ' + Exception.toString());
    }
  }
}
