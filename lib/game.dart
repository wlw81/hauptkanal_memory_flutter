import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hauptkanal_memory/main.dart';
import 'dart:developer' as developer;

import 'flags.dart';

class Game extends StatefulWidget {
  String currentStreet;

  Game(@required this.currentStreet);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<Game> {
  List imageNames = null;
  var randomImages;
  int currentNumber = 0;
  Image nextHouse;
  Image bitmapHouseAfter;

  _refillImages() {
    //developer.log('Refilling images, currently ' + randomImages.size() + ' in stock.');

    int randomHousenumber = -1;
    for (int i = 0; i < Flags.RANDOM_IMAGES; i++) {
      randomHousenumber = _generateHousenumber(randomHousenumber);
      //randomImages.add(scaleBitmap(randomHousenumber));
    }
    nextHouse = getImage(currentNumber);
    // bitmapHouseAfter = scaleBitmap(currentNumber + 1);
  }

  getImage(int p_houseNumber) {
    //String pathname = Directory('assets').path;
  }

  List _getImageNames() {
    if (null == imageNames) {
      imageNames = Directory('assets').listSync();
    }

    return imageNames;
  }

  int _generateHousenumber(int p_lastResult) {
    int houseNumberGenerated = currentNumber;
    while (houseNumberGenerated == currentNumber ||
        houseNumberGenerated == (currentNumber + 1) ||
        houseNumberGenerated == p_lastResult) {
      houseNumberGenerated = Random.secure().nextInt(_getImageNames().length);
    }
    return houseNumberGenerated;
  }

  _displayHousenumber() {
    _refillImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset('assets/hauptkanalLinks/image000.jpg')),
    );
  }
}
