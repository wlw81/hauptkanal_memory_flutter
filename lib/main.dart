import 'dart:convert';
import 'dart:developer' as developer;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'flags.dart';
import 'game.dart';
import 'l10n/app_localizations.dart';
import 'pbgLocalsLogo.dart';
import 'welcomeFlip.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audioContext =
      AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build();
  await AudioPlayer.global.setAudioContext(audioContext);

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            primary: Colors.purpleAccent,
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark),
        useMaterial3: true,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.purpleAccent,
        ),
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

  String leaderboardAndroid = Flags.LEADERBOARD_2018_RIGHT;
  String leaderboardIOS = Flags.LEADERBOARD_2018_RIGHT_IOS;

  String selectedStreet = Flags.STREET_2018_LEFT;

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

  playMusic() {
    assetsAudioPlayerMusic.setReleaseMode(ReleaseMode.loop);
    assetsAudioPlayerMusic
        .play(AssetSource('520937__mrthenoronha__8-bit-game-intro-loop.wav'));
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

  handleMenuClick(String pValue) {
    if (pValue == AppLocalizations.of(context)?.scoreboard) {
      showSelectedLeaderboard();
    } else {
      String info = AppLocalizations.of(context)!.legal;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(info, style: Theme.of(context).textTheme.bodyLarge),
          );
        },
      );
    }
  }

  void showSelectedLeaderboard() {
    Leaderboards.showLeaderboards(
        androidLeaderboardID: leaderboardAndroid,
        iOSLeaderboardID: leaderboardIOS);
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
            title: Center(
              child: Text(
                widget.title.toUpperCase(),
                style: GoogleFonts.robotoCondensed(
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                    fontSize: 32),
              ),
            ),
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: handleMenuClick,
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
          body: Stack(
            children: [
              ListView(children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                        bottom: 8, left: 20, right: 20, top: 20),
                    child: WelcomeFlip()),
                Padding(
                    padding: EdgeInsets.only(
                        bottom: 8, left: 20, right: 20, top: 20),
                    child: Card(
                        child: Column(
                      children: [
                        Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.only(
                                bottom: 8, left: 20, right: 20, top: 20),
                            child: Text(
                                AppLocalizations.of(context)!
                                    .selectStreet
                                    .toUpperCase(),
                                style: Theme.of(context).textTheme.bodyLarge)),
                        SegmentedButton<String>(
                          segments: [
                            ButtonSegment<String>(
                                value: Flags.STREET_2018_LEFT,
                                label: Text(getStreetNameForKey(
                                    Flags.STREET_2018_LEFT))),
                            ButtonSegment<String>(
                                value: Flags.STREET_2018_RIGHT,
                                label: Text(getStreetNameForKey(
                                    Flags.STREET_2018_RIGHT))),
                            ButtonSegment<String>(
                                value: Flags.STREET_2022_LEFT,
                                label: Text(getStreetNameForKey(
                                    Flags.STREET_2022_LEFT))),
                            ButtonSegment<String>(
                                value: Flags.STREET_2022_RIGHT,
                                label: Text(getStreetNameForKey(
                                    Flags.STREET_2022_RIGHT))),
                          ],
                          direction: Axis.vertical,
                          style: SegmentedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0)),
                          ),
                          multiSelectionEnabled: false,
                          onSelectionChanged: (p0) {
                            selectedStreet = p0.first;
                            switch (selectedStreet) {
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
                          },
                          selected: <String>{selectedStreet},
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                      ],
                    ))),
                PbgLocalsLogo(),
              ]),
            ],
          ),
          floatingActionButton: Column(
            children: [
              Spacer(),
              Visibility(
                visible: lastScore > 0,
                child: Column(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.lastScore + ': ',
                        style:
                        GoogleFonts.robotoCondensed(color: Colors.purple),
                      ),
                      Text(
                        lastScore.toString(),
                        style: GoogleFonts.robotoCondensed(
                            color: Colors.purple,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      )
                    ]),
              ),
              Container(
                width: 64,
                height: 64,
                margin: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  onPressed: _startGame,
                  child: Icon(Icons.play_arrow),
                ),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 27, 28, 30),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.deepPurple,
                          blurRadius: _animationFAB.value * 4,
                          spreadRadius: _animationFAB.value * 4)
                    ]),
              ),
            ],
          ),
        ),
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

  onScoreChange(int pValue, bool pFinal) {
    if (!pFinal) {
      setState(() {
        lastScore = pValue;
      });
    } else {
      playLevelFinishedMusic();
      firstRun();

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

      GamesServices.submitScore(
          score: Score(
              androidLeaderboardID: leaderboardAndroid,
              iOSLeaderboardID: leaderboardIOS,
              value: pValue));

      showSelectedLeaderboard();
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
    assetsAudioPlayerEffects
        .play(AssetSource('518305__mrthenoronha__stage-clear-8-bit.wav'));
    celebrated = true;
  }

  _startGame() async {
    assetsAudioPlayerMusic.pause();
    celebrated = false;
    assetsAudioPlayerEffects
        .play(AssetSource('516824__mrthenoronha__get-item-4-8-bit.wav'));
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
