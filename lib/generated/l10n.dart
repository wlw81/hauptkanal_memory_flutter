// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Hauptkanal Shuffle`
  String get app_name {
    return Intl.message(
      'Hauptkanal Shuffle',
      name: 'app_name',
      desc: '',
      args: [],
    );
  }

  /// `Score`
  String get score {
    return Intl.message('Score', name: 'score', desc: '', args: []);
  }

  /// `Last score`
  String get lastScore {
    return Intl.message('Last score', name: 'lastScore', desc: '', args: []);
  }

  /// `Hauptkanal left 2018`
  String get left2018 {
    return Intl.message(
      'Hauptkanal left 2018',
      name: 'left2018',
      desc: '',
      args: [],
    );
  }

  /// `Hauptkanal right 2018`
  String get right2018 {
    return Intl.message(
      'Hauptkanal right 2018',
      name: 'right2018',
      desc: '',
      args: [],
    );
  }

  /// `Hauptkanal left 2022 (at night)`
  String get left2022 {
    return Intl.message(
      'Hauptkanal left 2022 (at night)',
      name: 'left2022',
      desc: '',
      args: [],
    );
  }

  /// `Hauptkanal right 2022  (at night)`
  String get right2022 {
    return Intl.message(
      'Hauptkanal right 2022  (at night)',
      name: 'right2022',
      desc: '',
      args: [],
    );
  }

  /// `Can you reach the train station?\nTap on the next house and crack the high score!`
  String get introduction {
    return Intl.message(
      'Can you reach the train station?\nTap on the next house and crack the high score!',
      name: 'introduction',
      desc: '',
      args: [],
    );
  }

  /// `Coding & design: Thomas Pasligh (2022 photos: Philip Schöppe, QA: klokodax, music by Mrthenoronha)\n\nAll displayed image copyright remains by its respective owners.`
  String get legal {
    return Intl.message(
      'Coding & design: Thomas Pasligh (2022 photos: Philip Schöppe, QA: klokodax, music by Mrthenoronha)\n\nAll displayed image copyright remains by its respective owners.',
      name: 'legal',
      desc: '',
      args: [],
    );
  }

  /// `Leaderboard`
  String get scoreboard {
    return Intl.message('Leaderboard', name: 'scoreboard', desc: '', args: []);
  }

  /// `Select a street`
  String get selectStreet {
    return Intl.message(
      'Select a street',
      name: 'selectStreet',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
