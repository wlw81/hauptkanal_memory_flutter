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
    return MaterialApp(
      title: '123',
      home: Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Center(child: Image.asset('assets/hauptkanalLinks/image000.jpg')),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                    child: Card(child: Image.asset('assets/hauptkanalLinks/image001.jpg')),
                    width: 125,
                    height: 170),
                Container(
                    child: Card(child: Image.asset('assets/hauptkanalLinks/image002.jpg')),
                    width: 125,
                    height: 170),
                Card(
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      print('Card tapped.');
                    },
                    child: Container(
                      width: 300,
                      height: 100,
                      child: Text('A card that can be tapped'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
