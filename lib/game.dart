import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hauptkanal_memory/cardSelector.dart';
import "package:intl/intl.dart";

import 'flags.dart';

class Game extends StatefulWidget {
  final String currentStreet;

  Game(this.currentStreet);

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
  int score = 0;
  int lastRandomNumber;
  List<Image> _nextRandomImages;
  Timer _timer;
  int _start = Flags.COUNTDOWN_IN_SECONDS;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            try {
              timer.cancel();
            } finally {
              Navigator.pop(context);
            }
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
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

  int _generateHousenumber() {
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
    assetsAudioPlayer.play();
  }

  playWrongAudio() async {
    assetsAudioPlayer.open(Audio("assets/bad.mp3"));
    assetsAudioPlayer.play();
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
          score++;
          currentNumber++;
        });
      } else {
        playWrongAudio();
        score--;
      }
      developer.log('Current score: ' + score.toString());
    }
  }

  List<Image> _generateRandomCardImages() {
    if (_nextRandomImages == null || _nextRandomImages.isEmpty) {
      _nextRandomImages = new List();
      for (int i = 0; i < Flags.RANDOM_CARD_COUNT - 1; i++) {
        _nextRandomImages.add(getImage(_generateHousenumber()));
      }
      _nextRandomImages.add(getImage(currentNumber + 1));
      _nextRandomImages.shuffle();
    }
    return _nextRandomImages;
  }

  @override
  Widget build(BuildContext context) {
    if (_timer == null || !_timer.isActive) {
      startTimer();
    }

    return MaterialApp(
        title: 'Hauptkanal Memory',
        home: Scaffold(
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
              Center(
                  child: Text(_printDuration(Duration(seconds: _start)),
                      style: GoogleFonts.robotoCondensed(
                          fontSize: 95,
                          fontStyle: FontStyle.italic,
                          textStyle: TextStyle(color: Colors.white54)))),
              Container(
                  alignment: Alignment.topRight,
                  padding: EdgeInsets.all(25.0),
                  child: Text('Score ' + score.toString(),
                      style: GoogleFonts.roboto(
                          fontSize: 25,
                          textStyle: TextStyle(color: Colors.white54)))),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Expanded(
                    child: SizedBox(
                        height: 200,
                        child: Padding(
                            padding: EdgeInsets.only(
                                bottom: 10.5, left: 2.5, right: 2.5, top: 15.0),
                            child: CardSelector(_generateRandomCardImages(), _cardTapped)))),
              ])
            ],
          ),
        ));
  }

  void preCacheNextImage() async {
    try {
       precacheImage(
          Image.file(_getImageNames().elementAt(currentNumber)).image, context);
    } catch (Exception) {
      developer.log('Failed to pre cache: ' + Exception.toString());
    }
  }
}
