import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hauptkanal_memory/cards.dart';
import 'package:hauptkanal_memory/main.dart';
import 'dart:developer' as developer;
import "package:intl/intl.dart";
import 'dart:developer';

import 'flags.dart';

String currentStreet = Flags.STREET_LEFT;

class Game extends StatefulWidget {
  Game(currentStreet);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<Game> {
  List imageNames;
  var randomImages = List();
  int currentNumber = 0;
  int score = 0;
  Image nextHouse;
  Image bitmapHouseAfter;
  int lastRandomNumber;
  int selectedIndex = -1;
  List<Image> _generatedImages;

  _refillImages() {
    developer.log(
        'Refilling images, currently ' + randomImages.size() + ' in stock.');

    int randomHousenumber = -1;
    for (int i = 0; i < Flags.RANDOM_IMAGES; i++) {
      randomHousenumber = _generateHousenumber();
      //randomImages.add(scaleBitmap(randomHousenumber));
    }
    nextHouse = getImage(currentNumber);
    // bitmapHouseAfter = scaleBitmap(currentNumber + 1);
  }

  Image getImage(int p_houseNumber) {
    var myFormat = new NumberFormat();
    myFormat.minimumIntegerDigits = 3;
    var path = 'assets/' +
        currentStreet +
        '/image' +
        myFormat.format(p_houseNumber) +
        '.jpg';

    developer.log(path);
    return Image.asset(path);
  }

  Image getNextHouseImage() {
    return getImage(currentNumber++);
  }

  List _getImageNames() {
    if (imageNames.isEmpty) {
      var systemTempDir = Directory.systemTemp;

      // hier muss ich frickeln

      // List directory contents, recursing into sub-directories,
      // but not following symbolic links.
      systemTempDir
          .list(recursive: true, followLinks: false)
          .listen((FileSystemEntity entity) {
        if (entity.path.contains(currentStreet) &&
            entity.path.contains('jpg')) {
          imageNames.add(entity.path);
        }
      });
    }

    developer.log('Current image count: ' + imageNames.length.toString());
    return imageNames;
  }

  int _generateHousenumber() {
    int houseNumberGenerated = currentNumber;
    while (houseNumberGenerated == currentNumber ||
        houseNumberGenerated == (currentNumber + 1) ||
        houseNumberGenerated == lastRandomNumber) {
      if (null == imageNames) {
        houseNumberGenerated = Random.secure().nextInt(Flags.TEMP_IMG_COUNT);
      } else {
        houseNumberGenerated = Random.secure().nextInt(_getImageNames().length);
      }

    }
    lastRandomNumber = houseNumberGenerated;
    return houseNumberGenerated;
  }

  _displayHousenumber() {
    _refillImages();
  }

  _cardTapped(int p_selectedIndex) {
    if (p_selectedIndex > -1 && _generatedImages.isNotEmpty) {
      stdout.writeln('Card tapped.');
      selectedIndex = p_selectedIndex;
      String selectedFilename =
      _generatedImages.elementAt(p_selectedIndex).toStringShort();
      developer.log('Selected image: ' + selectedFilename);
      String correctFilename =
      _generatedImages.elementAt(currentNumber + 1).toStringShort();
      if (selectedFilename.compareTo(correctFilename) == 0) {
        score++;
      } else {
        score--;
      }
      developer.log('Current score: ' + score.toString());
    }
  }

  List<Image> _generateCardImages() {
    _generatedImages = new List();
    for (int i = 0; i < Flags.RANDOM_CARD_COUNT; i++) {
      _generatedImages.add(getImage(_generateHousenumber()));
    }
    return _generatedImages;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hauptkanal Memory',
      home: Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Center(child: getImage(0)),
            Center(child: Text('Score ' + score.toString())),
            Cards(_cardTapped(selectedIndex), _generateCardImages())
          ],
        ),
      ),
    );
  }
}
