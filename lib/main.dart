import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:games_services/games_services.dart';
import 'package:hauptkanalmemory/app_localizations.dart';
import 'package:hauptkanalmemory/flags.dart';
import 'package:hauptkanalmemory/game.dart';
import 'package:hauptkanalmemory/scoreDisplay.dart';
import 'package:hauptkanalmemory/welcomeFlip.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

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
          primaryColor: Colors.deepPurple[700],
          secondaryHeaderColor: Colors.deepPurple[100],
          fontFamily: 'Roboto',
          dividerColor: Colors.grey[400],
          textTheme: TextTheme(
              caption: TextStyle(color: Colors.grey[900]),
              bodyText1: TextStyle(color: Colors.white),
              bodyText2: TextStyle(color: Colors.grey[600])),
          accentColor: Colors.purpleAccent),
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

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin, WidgetsBindingObserver {
  int lastScore = 0;
  bool celebrated = false;

  AnimationController _controller;
  AnimationController _controllerScore;
  Animation<Offset> _offsetAnimation;
  Animation<Offset> _offsetAnimationScore;
  final assetsAudioPlayerEffects = AssetsAudioPlayer();
  final assetsAudioPlayerMusic = AssetsAudioPlayer();

  Map<String, bool> values = {
    Flags.STREET_LEFT: true,
    Flags.STREET_RIGHT: false,
  };

  playMusic() async {
    assetsAudioPlayerMusic.open(Audio("assets/520937__mrthenoronha__8-bit-game-intro-loop.wav"), loopMode: LoopMode.single);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    playMusic();
    _controller = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat(reverse: true);
    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.5, 0.0),
    ).animate(_controller);

    _controllerScore = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _offsetAnimationScore = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.2, 0.0),
    ).animate(CurvedAnimation(
      parent: _controllerScore,
      curve: Curves.elasticIn,
    ));

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
  dispose(){
    WidgetsBinding.instance.removeObserver(this);
    assetsAudioPlayerMusic.stop();
    assetsAudioPlayerEffects.stop();
    super.dispose();
  }

  handleMenuClick(String pValue) {
    if (pValue == AppLocalizations.of(context).translate('scoreboard')) {
      GamesServices.showLeaderboards();
    } else {
      String info = AppLocalizations.of(context).translate('legal');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).dividerColor,
            title: Text(info, style: Theme.of(context).textTheme.bodyText1),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          //
          child: SlideTransition(
            position: _offsetAnimation,
            child: OverflowBox(
              minWidth: 0.0,
              minHeight: 0.0,
              maxWidth: double.infinity,
              child: Image(
                image: AssetImage('assets/background.jpg'),
              ),
            ),
          ),
        ),
        Scaffold(
            backgroundColor: Colors.transparent,
            // <-- SCAFFOLD WITH TRANSPARENT BG
            appBar: AppBar(
              title: Text(widget.title),
              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: handleMenuClick,
                  itemBuilder: (BuildContext context) {
                    return <String>[
                      AppLocalizations.of(context).translate('scoreboard'),
                      AppLocalizations.of(context).translate('about')
                    ].map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            body: ListView(children: <Widget>[
              Padding(
                  padding:
                      EdgeInsets.only(bottom: 8, left: 20, right: 20, top: 20),
                  child: WelcomeFlip()),
              Padding(
                  padding:
                      EdgeInsets.only(bottom: 8, left: 20, right: 20, top: 20),
                  child: Card(
                      color: Theme.of(context).primaryColor,
                      child: Column(
                        children: [
                          Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(
                                  bottom: 8, left: 20, right: 20, top: 20),
                              child: Text(
                                  AppLocalizations.of(context)
                                      .translate('selectStreet'),
                                  style:
                                      Theme.of(context).textTheme.bodyText1)),
                          Column(
                            children: values.keys.map((String key) {
                              return CheckboxListTile(
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(
                                    AppLocalizations.of(context).translate(key),
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
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
                        ],
                      ))),
            ]),
            floatingActionButton: FloatingActionButton(
              onPressed: _startGame,
              child: Icon(Icons.play_arrow),
            )),
        SlideTransition(position: _offsetAnimationScore,child: ScoreDisplay(lastScore, false)) ],
    );
  }

  onScoreChange(int pValue, bool pFinal) async {
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
          score: Score(androidLeaderboardID: leaderBoardID, value: pValue));

      GamesServices.showLeaderboards();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed ){
      if(lastScore >0 && !celebrated){
        playLevelFinishedMusic();
        celebrated = true;
      }else{
        assetsAudioPlayerMusic.play();
      }
    }else if (state == AppLifecycleState.paused){
      assetsAudioPlayerMusic.pause();
    }
  }

  playLevelFinishedMusic() async {
    assetsAudioPlayerMusic.stop();
    assetsAudioPlayerEffects.open(Audio("assets/518305__mrthenoronha__stage-clear-8-bit.wav"));
  }

  _startGame() async {
    assetsAudioPlayerMusic.pause();
    celebrated = false;
    await assetsAudioPlayerEffects.open(Audio("assets/516824__mrthenoronha__get-item-4-8-bit.wav"));
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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
