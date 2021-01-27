import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hauptkanalmemory/app_localizations.dart';
import 'package:hauptkanalmemory/flags.dart';
import 'package:hauptkanalmemory/game.dart';
import 'package:hauptkanalmemory/scoreDisplay.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:games_services/games_services.dart';
import 'package:hauptkanalmemory/welcomeFlip.dart';

import 'flags.dart';

void main() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    bool inDebug = false;
    assert(() {
      inDebug = true;
      return true;
    }());
    // In debug mode, use the normal error widget which shows
    // the error message:
    if (inDebug) return ErrorWidget(details.exception);
    // In release builds, show a yellow-on-blue message instead:
    return Container(
      alignment: Alignment.center,
      child: Text(
        'Error! ${details.exception}',
        style: TextStyle(color: Colors.yellow),
        textDirection: TextDirection.ltr,
      ),
    );
  };
  // Here we would normally runApp() the root widget, but to demonstrate
  // the error handling we artificially fail:
  return runApp(MyApp());
}

final String appName = 'Hauptkanal Memory';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.purple,
          secondaryHeaderColor: Colors.purple[100],
          fontFamily: 'Roboto',
          textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.purple)),
          accentColor: Colors.orangeAccent),
      supportedLocales: [Locale('en', ''), Locale('de', '')],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        // If the locale of the device is not supported, use the first one
        // from the list (English, in this case).
        return supportedLocales.first;
      },
      home: MyHomePage(
        title: appName,
      ),
      title: appName,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int lastScore = 0;
  String _platformVersion = 'Unknown';
  Map<String, bool> values = {
    Flags.STREET_LEFT: true,
    Flags.STREET_RIGHT: false,
  };

  @override
  void initState() {
    super.initState();
    welcome();
  }

  welcome() async {
    await GamesServices.signIn();
    GamesServices.unlock(
        achievement:
            Achievement(androidID: Flags.ACHV_WELCOME, percentComplete: 100));
  }

  firstRun() async {
    return GamesServices.unlock(
        achievement:
            Achievement(androidID: Flags.ACHV_FIRSTRUN, percentComplete: 100));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).secondaryHeaderColor,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(children: <Widget>[
          Padding(
              padding: EdgeInsets.only(bottom: 8, left: 8, right: 8, top: 20),
              child: ScoreDisplay(lastScore, false)),
          ElevatedButton(onPressed: ()  => GamesServices.showLeaderboards() , child: Text(AppLocalizations.of(context).translate('scoreboard'))),
          Padding(
              padding: EdgeInsets.only(bottom: 8, left: 20, right: 20, top: 20),
              child:
              WelcomeFlip()),
            ListView(
              shrinkWrap: true,
              padding:
              EdgeInsets.only(bottom: 10.5, left: 15, right: 15, top: 15.0),
              children: values.keys.map((String key) {
                return CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(AppLocalizations.of(context).translate(key),   style: Theme.of(context).textTheme.bodyText1),
                  value: values[key],
                  onChanged: (bool value) {
                    setState(() {
                      if (key == Flags.STREET_LEFT) {
                        values[Flags.STREET_LEFT] = true;
                        values[Flags.STREET_RIGHT] = false;
                      } else if (key == Flags.STREET_RIGHT) {
                        values[Flags.STREET_LEFT] = false;
                        values[Flags.STREET_RIGHT] = true;
                      }
                    });
                  },
                );
              }).toList(),
            ),




        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: _startGame,
          child: Icon(Icons.play_arrow),
        ));
  }

  onScoreChange(int pValue, bool pFinal) async{
    if (!pFinal) {
      setState(() {
        lastScore = pValue;
      });
    } else {
      await firstRun();
      String leaderBoardID = 'error';
      (values[Flags.STREET_LEFT])
          ? leaderBoardID = Flags.LEADERBORD_LEFT
          : leaderBoardID = Flags.LEADERBORD_RIGHT;

      await GamesServices.submitScore(
          score: Score(
              androidLeaderboardID: leaderBoardID,
              value: pValue));

      GamesServices.showLeaderboards();
    }
  }

  _startGame() async {
    String flag = 'error';
    (values[Flags.STREET_LEFT])
        ? flag = Flags.STREET_LEFT
        : flag = Flags.STREET_RIGHT;

    // >> To get paths you need these 2 lines
    final manifestContent =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // >> To get paths you need these 2 lines

    final imagePaths = manifestMap.keys
        .where((String key) => key.contains(flag))
        .where((String key) => key.contains('.jpg'))
        .toList();

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      developer.log('Selected street ' + flag);
      return Game(flag, onScoreChange, imagePaths);
    }));
  }
}
