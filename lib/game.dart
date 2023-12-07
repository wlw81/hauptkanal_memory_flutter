import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:hauptkanalmemory/cardSelector.dart';
import 'package:hauptkanalmemory/countdown.dart';
import 'package:hauptkanalmemory/scoreDisplay.dart';
import 'package:wakelock/wakelock.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';

import 'flags.dart';

class Game extends StatefulWidget {
  final Function(int, bool) onScoreChange;
  final List<String> streetImageNames;

  Game(this.onScoreChange, this.streetImageNames);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<Game>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final assetsAudioPlayer = AssetsAudioPlayer();
  final assetsAudioPlayerMusic = AssetsAudioPlayer();
  int currentNumber = 0;
  int lastRandomNumber = 0;
  int score = 0;
  Map<int, Image> _nextRandomImages = new HashMap<int, Image>();
  int secondsRemaining = Flags.COUNTDOWN_IN_SECONDS;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    playMusic();

    if (!_timer.isActive) {
      startTimer();
    }

    WidgetsBinding.instance.addObserver(this);
    Wakelock.enable();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 0.01),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  close(bool pSubmitFinal) {
    if (pSubmitFinal) {
      submitScore(true);
      Navigator.pop(context);
    } else {
      dispose();
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    try {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
      assetsAudioPlayerMusic.stop();
      assetsAudioPlayer.stop();
      WidgetsBinding.instance.removeObserver(this);
      _timer.cancel();
      _controller.dispose();
      Wakelock.disable();
    } finally {
      super.dispose();
      submitScore(true);
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
              close(true); // out of time
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

  submitScore(bool pFinalScore) {
    if (pFinalScore) {
      developer.log('Final score ' + score.toString());
      widget.onScoreChange(score, true);
    } else {
      widget.onScoreChange(0, false);
    }
  }

  int _generateHouseNumber() {
    int houseNumberGenerated = currentNumber;
    while (houseNumberGenerated == currentNumber ||
        houseNumberGenerated == (currentNumber + 1) ||
        houseNumberGenerated == lastRandomNumber) {
      houseNumberGenerated =
          Random.secure().nextInt(widget.streetImageNames.length);
    }
    lastRandomNumber = houseNumberGenerated;
    return houseNumberGenerated;
  }

  playFlickAudio() async {
    assetsAudioPlayer.open(Audio("assets/flick.wav"));
  }

  playMusic() async {
    assetsAudioPlayerMusic.open(
        Audio("assets/515615__mrthenoronha__8-bit-game-theme.wav"),
        loopMode: LoopMode.single);
  }

  playWrongAudio() async {
    try {
      if (await (Vibration.hasVibrator()) ?? false) {
        Vibration.vibrate(duration: 200);
      }
    } finally {
      assetsAudioPlayer.open(Audio("assets/bad.mp3"));
    }
  }

  _cardTapped(int pSelectedIndex) {
    developer.log('Confirmed card tapped: ' + pSelectedIndex.toString());
    if (pSelectedIndex > -1 && _nextRandomImages.isNotEmpty) {
      _controller.forward(from: 0.0);

      // check tomorrow is this really works
      if (_nextRandomImages.keys.elementAt(pSelectedIndex) ==
          (currentNumber + 1)) {
        playFlickAudio();
        preCacheNextImage();

        setState(() {
          _nextRandomImages.clear();
          int additionalScore = 10 * secondsRemaining;
          score += additionalScore;
          currentNumber++;
        });

        if (currentNumber >= (widget.streetImageNames.length - 2)) {
          close(true); // game completed!
        }
      } else {
        playWrongAudio();
        setState(() {
          score -= 500;
        });
      }
      widget.onScoreChange(score, false);
      developer.log('Current score: ' + score.toString());
    }
  }

  Map<int, Image> _generateRandomCardImages() {
    if (_nextRandomImages.isEmpty) {
      HashMap newRandomImagesUnsorted = new HashMap<int, Image>();
      for (int i = 0; i < Flags.RANDOM_CARD_COUNT - 1; i++) {
        int number = _generateHouseNumber();
        newRandomImagesUnsorted.putIfAbsent(
            number,
            () => Image.asset(
                  widget.streetImageNames.elementAt(number),
                  fit: BoxFit.cover,
                ));
      }
      newRandomImagesUnsorted.putIfAbsent(
          currentNumber + 1,
          () => Image.asset(
              widget.streetImageNames.elementAt(currentNumber + 1),
              fit: BoxFit.cover));
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
            child: Image.asset(widget.streetImageNames.elementAt(currentNumber),
                fit: BoxFit.cover),
          ),
          Center(child: Countdown(secondsRemaining)),
          SlideTransition(
              position: _offsetAnimation, child: ScoreDisplay(score, true)),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Expanded(
                child: SizedBox(
                    height: 200,
                    child: Padding(
                        padding: EdgeInsets.only(
                            bottom: 20.5, left: 2.5, right: 2.5, top: 20.0),
                        child: CardSelector(
                            _generateRandomCardImages().values.toList(),
                            _cardTapped)))),
          ])
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive) {
      close(false);
    } else if (state == AppLifecycleState.paused) {
      assetsAudioPlayerMusic.pause();
    }
  }

  void preCacheNextImage() async {
    try {
      for (int i = 0; i < Flags.RANDOM_CARD_COUNT; i++) {
        int renderNumber = currentNumber + i;
        if (renderNumber < widget.streetImageNames.length) {
          precacheImage(
              Image.asset(widget.streetImageNames.elementAt(renderNumber))
                  .image,
              context);
        }
      }
    } catch (e) {
      developer.log('Failed to pre cache: ' + e.toString());
    }
  }
}
