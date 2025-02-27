import 'dart:convert';
import 'dart:developer' as developer;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hauptkanalmemory/flags.dart';
import 'package:hauptkanalmemory/game.dart';
import 'package:hauptkanalmemory/l10n/app_localizations.dart';
import 'package:hauptkanalmemory/welcomeFlip.dart';

import 'pbgLocalsLogo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

final String appName = 'Hauptkanal Shuffle';

final ThemeData theme = ThemeData();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: theme.copyWith(
        primaryColor: Colors.deepPurple[700],
        secondaryHeaderColor: Colors.deepPurple[100],
        canvasColor: Colors.deepPurple[100],
        colorScheme: theme.colorScheme.copyWith(
          secondary: Colors.purpleAccent,
          primary: Colors.deepPurple[700],
        ),
        dividerColor: Colors.grey[400],
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.purpleAccent,
        ),
        textTheme: TextTheme(
            bodySmall: TextStyle(color: Colors.grey[900]),
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.deepPurple[100])),
      ),
      home: MyHomePage(appName),
      title: appName,
    );
  }
}

class _MyHomePageState extends State<MyHomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int lastScore = 0;
  bool celebrated = false;

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  late AnimationController _animationControllerFAB;
  late Animation _animationFAB;

  final assetsAudioPlayerEffects = AudioPlayer();
  final assetsAudioPlayerMusic = AudioPlayer();

  Map<String, bool> values = {
    Flags.STREET_2018_LEFT: false,
    Flags.STREET_2018_RIGHT: false,
    Flags.STREET_2022_LEFT: true,
    Flags.STREET_2022_RIGHT: false,
  };

  playMusic() async {
    assetsAudioPlayerMusic.setReleaseMode(ReleaseMode.loop);
    assetsAudioPlayerMusic.play(
        AssetSource('assets/520937__mrthenoronha__8-bit-game-intro-loop.wav'));
  }

  @override
  void initState() {
    super.initState();
    GameAuth.signIn();
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

    _animationControllerFAB =
        AnimationController(vsync: this, duration: Duration(seconds: 8));
    _animationControllerFAB.repeat(reverse: true);
    _animationFAB =
        Tween(begin: 2.0, end: 15.0).animate(_animationControllerFAB)
          ..addListener(() {
            setState(() {});
          });

    welcome();
  }

  welcome() async {
    final result = await GameAuth.signIn();
    print('GameAuth Sign In ' + result.toString());

    final result3 = await GameAuth.isSignedIn;
    print('Sign in check result' + result3.toString());

    await Achievements.unlock(
        achievement: Achievement(
            androidID: Flags.ACHV_WELCOME,
            iOSID: Flags.ACHV_WELCOME_IOS,
            percentComplete: 100));
  }

  firstRun() async {
    return await Achievements.unlock(
        achievement: Achievement(
            androidID: Flags.ACHV_FIRSTRUN,
            iOSID: Flags.ACHV_FIRSTRUN_IOS,
            percentComplete: 100));
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    assetsAudioPlayerMusic.stop();
    assetsAudioPlayerEffects.stop();
    super.dispose();
  }

  handleMenuClick(String pValue) async {
    if (pValue == AppLocalizations.of(context)?.scoreboard) {
      final result = await Leaderboards.loadLeaderboardScores(
          scope: PlayerScope.global,
          timeScope: TimeScope.allTime,
          maxResults: 10);
      print(result);
    } else {
      String info = AppLocalizations.of(context)!.legal;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).dividerColor,
            title: Text(info, style: Theme.of(context).textTheme.bodyLarge),
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
          child: SlideTransition(
            position: _offsetAnimation,
            child: OverflowBox(
              minWidth: 0.0,
              minHeight: 0.0,
              maxWidth: double.infinity,
              child: Image(
                fit: BoxFit.cover,
                image: AssetImage('assets/background.jpg'),
              ),
            ),
          ),
        ),
        Scaffold(
            backgroundColor: Colors.transparent,
            // <-- SCAFFOLD WITH TRANSPARENT BG
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                widget.title,
                style:
                    GoogleFonts.roboto(color: Theme.of(context).primaryColor),
              ),
              actions: <Widget>[
                PopupMenuButton<String>(
                  onSelected: handleMenuClick,
                  color: Theme.of(context).primaryColor,
                  itemBuilder: (BuildContext context) {
                    return <String>[
                      AppLocalizations.of(context)!.scoreboard,
                      AppLocalizations.of(context)!.about
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
                                      !.selectStreet
                                      .toUpperCase(),
                                  style:
                                      Theme.of(context).textTheme.bodyLarge)),
                          Column(
                            children: values.keys.map((String key) {
                              return CheckboxListTile(
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(getStreetNameForKey(key),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                                value: values[key],
                                onChanged: (bool? value) {
                                  setState(() {
                                    switch (key) {
                                      case Flags.STREET_2018_LEFT:
                                        values[Flags.STREET_2018_LEFT] = true;
                                        values[Flags.STREET_2018_RIGHT] = false;
                                        values[Flags.STREET_2022_LEFT] = false;
                                        values[Flags.STREET_2022_RIGHT] = false;
                                        break;
                                      case Flags.STREET_2018_RIGHT:
                                        values[Flags.STREET_2018_LEFT] = false;
                                        values[Flags.STREET_2018_RIGHT] = true;
                                        values[Flags.STREET_2022_LEFT] = false;
                                        values[Flags.STREET_2022_RIGHT] = false;
                                        break;
                                      case Flags.STREET_2022_LEFT:
                                        values[Flags.STREET_2018_LEFT] = false;
                                        values[Flags.STREET_2018_RIGHT] = false;
                                        values[Flags.STREET_2022_LEFT] = true;
                                        values[Flags.STREET_2022_RIGHT] = false;
                                        break;
                                      case Flags.STREET_2022_RIGHT:
                                      default:
                                        values[Flags.STREET_2018_LEFT] = false;
                                        values[Flags.STREET_2018_RIGHT] = false;
                                        values[Flags.STREET_2022_LEFT] = false;
                                        values[Flags.STREET_2022_RIGHT] = true;
                                        break;
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ))),
              PbgLocalsLogo(),
            ]),
            floatingActionButton: Container(
              width: 64,
              height: 64,
              margin: const EdgeInsets.all(32.0),
              child: FloatingActionButton(
                onPressed: _startGame,
                child: Icon(Icons.play_arrow),
              ),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 27, 28, 30),
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context).primaryColor,
                        blurRadius: _animationFAB.value * 4,
                        spreadRadius: _animationFAB.value * 4)
                  ]),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked),
      ],
    );
  }

  String getStreetNameForKey(String key) {
    switch (key) {
      case Flags.STREET_2018_LEFT:
        return AppLocalizations.of(context)!.left2018;
      case Flags.STREET_2018_RIGHT:
        return AppLocalizations.of(context)!.right2018;
      case Flags.STREET_2022_LEFT:
        return AppLocalizations.of(context)!.left2022;
      case Flags.STREET_2022_RIGHT:
      default:
        return AppLocalizations.of(context)!.right2022;
    }
  }

  onScoreChange(int pValue, bool pFinal) async {
    if (!pFinal) {
      setState(() {
        lastScore = pValue;
      });
    } else {
      playLevelFinishedMusic();
      await firstRun();

      String leaderboardAndroid = Flags.LEADERBOARD_2018_RIGHT;
      String leaderboardIOS = Flags.LEADERBOARD_2018_RIGHT_IOS;

      if (values[Flags.STREET_2018_LEFT] ?? false) {
        leaderboardAndroid = Flags.LEADERBOARD_2018_LEFT;
        leaderboardIOS = Flags.LEADERBAORD_2018_LEFT_IOS;
      } else if (values[Flags.STREET_2022_LEFT] ?? false) {
        leaderboardAndroid = Flags.LEADERBOARD_2022_LEFT;
        leaderboardIOS = Flags.LEADERBAORD_2022_LEFT_IOS;
      } else if (values[Flags.STREET_2022_RIGHT] ?? false) {
        leaderboardAndroid = Flags.LEADERBOARD_2022_RIGHT;
        leaderboardIOS = Flags.LEADERBOARD_2022_RIGHT_IOS;
      }

      await GamesServices.submitScore(
          score: Score(
              androidLeaderboardID: leaderboardAndroid,
              iOSLeaderboardID: leaderboardIOS,
              value: pValue));

      GamesServices.showLeaderboards(iOSLeaderboardID: leaderboardIOS);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (celebrated || lastScore == 0) {
        assetsAudioPlayerMusic.resume();
      }
    } else if (state == AppLifecycleState.paused) {
      assetsAudioPlayerMusic.pause();
    }
  }

  playLevelFinishedMusic() async {
    assetsAudioPlayerMusic.stop();
    assetsAudioPlayerEffects.play(
        AssetSource('assets/518305__mrthenoronha__stage-clear-8-bit.wav'));
    celebrated = true;
  }

  _startGame() async {
    assetsAudioPlayerMusic.pause();
    celebrated = false;
    assetsAudioPlayerEffects
        .play(AssetSource('assets/516824__mrthenoronha__get-item-4-8-bit.wav'));
    String flag = 'error';
    values.forEach((key, value) {
      if (value == true) {
        flag = key;
        developer.log('Selected street ' + flag);
      }
    });

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
      developer.log('Starting in street ' + flag);
      return Game(onScoreChange, imagePaths);
    }));
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage(this.title);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}
