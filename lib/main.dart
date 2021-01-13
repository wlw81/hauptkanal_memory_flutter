import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hauptkanal_memory/app_localizations.dart';
import 'package:hauptkanal_memory/flags.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hauptkanal_memory/game.dart';

void main() => runApp(MyApp());

final String appName = 'Hauptkanal Memory';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      supportedLocales: [Locale('en', ''), Locale('de', '')],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
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
  int score = 0;

  Map<String, bool> values = {
    Flags.STREET_LEFT: true,
    Flags.STREET_RIGHT: false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(children: <Widget>[
          Padding(
              padding: EdgeInsets.only(bottom: 8, left: 8, right: 8, top: 20),
              child: Text(AppLocalizations.of(context).translate('score') +
                  ' ' +
                  score.toString(), style: GoogleFonts.roboto(
                  fontSize: 25,
                  textStyle: TextStyle(color: Colors.purple)))),
          Expanded(
            child: ListView(
              padding:
                  EdgeInsets.only(bottom: 10.5, left: 10, right: 10, top: 15.0),
              children: values.keys.map((String key) {
                return CheckboxListTile(
                  title: Text(AppLocalizations.of(context).translate(key)),
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
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: _startGame,
          child: Icon(Icons.play_arrow),
        ));
  }

  void _startGame() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      String flag = 'error';
      (values[Flags.STREET_LEFT])
          ? flag = Flags.STREET_LEFT
          : flag = Flags.STREET_RIGHT;
      return Game(flag, score);
    }));
  }
}
