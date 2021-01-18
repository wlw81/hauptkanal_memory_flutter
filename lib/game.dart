import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:hauptkanal_memory/cardSelector.dart';
import 'package:hauptkanal_memory/countdown.dart';
import 'package:hauptkanal_memory/score.dart';
import "package:intl/intl.dart";

import 'flags.dart';

class Game extends StatefulWidget {
  final String currentStreet;
  final Function(int) onScoreChange;

  Game(this.currentStreet, this.onScoreChange);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<Game> with TickerProviderStateMixin {
  final assetsAudioPlayer = AssetsAudioPlayer();
  List<FileSystemEntity> imageNames;
  List randomImages;
  int currentNumber = 0;
  int lastRandomNumber;
  int score = 0;
  List<Image> _nextRandomImages;
  int secondsRemaining = Flags.COUNTDOWN_IN_SECONDS;

  Timer _timer;

  @override
  void initState() {
    super.initState();
    if (_timer == null || !_timer.isActive) {
      startTimer();
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
              close();
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


  Image getImage(int pHouseNumber) {
    var myFormat = new NumberFormat();
    myFormat.minimumIntegerDigits = 3;
    var path = 'assets/' +
        widget.currentStreet +
        '/image' +
        myFormat.format(pHouseNumber) +
        '.jpg';

    return Image.asset(path);
  }

  close() {
    setState(() {
      dispose();
      developer.log('Final score ' + score.toString());
      Navigator.pop(context);
    });
  }

  List<FileSystemEntity> _getImageNames() {
    if (imageNames == null || imageNames.isEmpty) {
      imageNames = List<FileSystemEntity>();
      var systemTempDir = Directory.systemTemp;

      // List directory contents, recursing into sub-directories,
      // but not following symbolic links.
      systemTempDir.listSync(recursive: true, followLinks: false).forEach(
          (element) => (element.path.contains(widget.currentStreet) &&
                  element.path.contains('jpg'))
              ? imageNames.add(element)
              : developer.log('not my beer -> ' + element.toString()));

      imageNames.sort((a, b) => a.toString().compareTo(b.toString()));
      imageNames.forEach((element) =>
          developer.log('Added to image list: ' + element.path.toString()));
      developer.log('Current image count: ' + imageNames.length.toString());
    }
    return imageNames;
  }

  int _generateHouseNumber() {
    int houseNumberGenerated = currentNumber;
    while (houseNumberGenerated == currentNumber ||
        houseNumberGenerated == (currentNumber + 1) ||
        houseNumberGenerated == lastRandomNumber) {
      houseNumberGenerated = Random.secure().nextInt(_getImageNames().length);
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
      String selectedFilename =
          _nextRandomImages.elementAt(pSelectedIndex).toString();
      String correctFilename = getImage(currentNumber + 1).toString();
      correctFilename =
          correctFilename.substring(correctFilename.lastIndexOf('/'));
      correctFilename =
          correctFilename.substring(0, correctFilename.indexOf('jpg'));

      developer.log('Selected image: ' +
          selectedFilename +
          ', correct image: ' +
          correctFilename);

      if (selectedFilename.contains(correctFilename)) {
        playFlickAudio();
        preCacheNextImage();

        setState(() {
          _nextRandomImages.clear();
          int additionalScore = 10 * secondsRemaining;
          score+= additionalScore;
          currentNumber++;
        });
      } else {
        playWrongAudio();
        setState(() {
          score-= 500;
        });
      }
      widget.onScoreChange(score);
      developer.log('Current score: ' + score.toString());
    }
  }

  List<Image> _generateRandomCardImages() {
    if (_nextRandomImages == null || _nextRandomImages.isEmpty) {
      _nextRandomImages = new List();
      for (int i = 0; i < Flags.RANDOM_CARD_COUNT - 1; i++) {
        _nextRandomImages.add(getImage(_generateHouseNumber()));
      }
      _nextRandomImages.add(getImage(currentNumber + 1));
      _nextRandomImages.shuffle();
    }
    return _nextRandomImages;
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
                height: double.infinity,
                width: double.infinity,
                child: Image.file(
                  _getImageNames().elementAt(currentNumber),
                  fit: BoxFit.cover,
                )),
            Center(child: Countdown(secondsRemaining)),
            Score(score, true),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              Expanded(
                  child: SizedBox(
                      height: 200,
                      child: Padding(
                          padding: EdgeInsets.only(
                              bottom: 20.5, left: 2.5, right: 2.5, top: 20.0),
                          child: CardSelector(
                              _generateRandomCardImages(), _cardTapped)))),
            ])
          ],
        ),
      )
    ;
  }

  void preCacheNextImage() async {
    try {
      for (int i = 0; i < Flags.RANDOM_CARD_COUNT; i++) {
        int renderNumber = currentNumber + i;
        if (renderNumber < _getImageNames().length) {
          precacheImage(
              Image.file(_getImageNames().elementAt(renderNumber)).image,
              context);
        }
      }
    } catch (Exception) {
      developer.log('Failed to pre cache: ' + Exception.toString());
    }
  }
}
