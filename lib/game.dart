import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hauptkanal_memory/main.dart';
import 'dart:developer' as developer;
import "package:intl/intl.dart";

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
  List<FileSystemEntity> imageNames;
  List randomImages;
  int currentNumber = 0;
  int score = 0;
  Image nextHouse;
  Image bitmapHouseAfter;
  int lastRandomNumber;
  List<Image> _nextRandomImages;

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

  List<FileSystemEntity> _getImageNames() {
    if (imageNames == null || imageNames.isEmpty) {
      imageNames = List<FileSystemEntity>();
      var systemTempDir = Directory.systemTemp;

      // List directory contents, recursing into sub-directories,
      // but not following symbolic links.
      systemTempDir.listSync(recursive: true, followLinks: false).forEach(
          (element) => (element.path.contains(currentStreet) &&
                  element.path.contains('jpg'))
              ? imageNames.add(element)
              : developer.log('not my beer -> '+element.toString()));

      imageNames.forEach((element) => developer.log('Added to image list: '+element.path.toString()));
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

  _cardTapped(int p_selectedIndex) {
    developer.log('Confirmed card tapped: ' + p_selectedIndex.toString());
    if (p_selectedIndex > -1 && _nextRandomImages.isNotEmpty) {
      String selectedFilename =
          _nextRandomImages.elementAt(p_selectedIndex).toString();
      String correctFilename =
          getImage(currentNumber + 1 ).toString();
      correctFilename =
          correctFilename.substring(correctFilename.lastIndexOf('/'));
      correctFilename =
          correctFilename.substring(0, correctFilename.indexOf('jpg'));

      developer.log('Selected image: ' +
          selectedFilename +
          ', correct image: ' +
          correctFilename);

      setState(() {
        if (selectedFilename.contains(correctFilename)) {
          score++;
          currentNumber++;
        } else {
          score--;
        }
        developer.log('Current score: ' + score.toString());
      });
    }
  }

  List<Image> _generateRandomCardImages() {
    _nextRandomImages = new List();
    for (int i = 0; i < Flags.RANDOM_CARD_COUNT - 1; i++) {
      _nextRandomImages.add(getImage(_generateHousenumber()));
    }
    _nextRandomImages.add(getImage(currentNumber + 1));
    return _nextRandomImages;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Hauptkanal Memory',
        home: Scaffold(
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Center(child: getImage(currentNumber)),
              Container(
                  alignment: Alignment.topRight,
                  padding: EdgeInsets.all(25.0),
                  child: Text('Score ' + score.toString(),
                      style: TextStyle(color: Colors.red, fontSize: 20.0))),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Expanded(
                    child: SizedBox(
                  height: 200,
                  child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: Flags.RANDOM_CARD_COUNT,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          child: Card(
                            elevation: 5,
                            child: _generateRandomCardImages().elementAt(index),
                          ),
                          onTap: () => _cardTapped(index),
                        );
                      }),
                )),
              ])
            ],
          ),
        ));
  }
}
