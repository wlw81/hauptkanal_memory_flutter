import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hauptkanal_memory/cards.dart';
import 'package:hauptkanal_memory/main.dart';
import 'dart:developer' as developer;
import "package:intl/intl.dart";

import 'flags.dart';

String currentStreet;

class Game extends StatefulWidget {
  Game(currentStreet);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<Game> {
  List imageNames = null;
  var randomImages;
  int currentNumber = 0;
  int score = 0;
  Image nextHouse;
  Image bitmapHouseAfter;
  int lastRandomNumber;
  int selectedIndex = -1;
  List<Image> _generatedImages;

  _refillImages() {
    //developer.log('Refilling images, currently ' + randomImages.size() + ' in stock.');

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

    return Image.asset('assets/' +
        currentStreet +
        '/image' +
        myFormat.format(p_houseNumber) +
        '.jpg');
  }

  Image getNextHouseImage() {
    return getImage(currentNumber++);
  }

  List _getImageNames() {
    if (null == imageNames) {
      imageNames = Directory('assets').listSync();
    }

    return imageNames;
  }

  int _generateHousenumber() {
    int houseNumberGenerated = currentNumber;
    while (houseNumberGenerated == currentNumber ||
        houseNumberGenerated == (currentNumber + 1) ||
        houseNumberGenerated == lastRandomNumber) {
      houseNumberGenerated = Random.secure().nextInt(_getImageNames().length);
      lastRandomNumber = houseNumberGenerated;
    }
    return houseNumberGenerated;
  }

  _displayHousenumber() {
    _refillImages();
  }

  _cardTapped(int p_selectedIndex) {
    selectedIndex = p_selectedIndex;
    String selectedFilename = _generatedImages.elementAt(p_selectedIndex).toStringShort();


    score++;
    print('Card tapped.');
  }

  List<Image> _generateCardImages(){
    _generatedImages = new List();
    for(int i = 0; i < Flags.RANDOM_CARD_COUNT; i++){
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
            Cards(_cardTapped(selectedIndex),_generateCardImages())
          ],
        ),
      ),
    );
  }
}
