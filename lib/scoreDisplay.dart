
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hauptkanalmemory/app_localizations.dart';
import "package:intl/intl.dart";

class ScoreDisplay extends StatelessWidget {

  final bool currentGame;
  final int _value;

  ScoreDisplay(this._value, this.currentGame);

  final NumberFormat _format = NumberFormat('###,###,000', 'de_DE');

  @override
  Widget build(BuildContext context) {
      return Container(
          alignment: Alignment.topRight ,
          padding: EdgeInsets.all(25.0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Container(
                padding: EdgeInsets.all(4.0),
                color: Theme.of(context).colorScheme.primary,
                child: Text(
                    ( (currentGame) ? AppLocalizations.of(context).translate('score') +' '+_format.format(_value):  'Start →'),
                    style: GoogleFonts.robotoCondensed(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        textStyle: TextStyle(
                          decoration: TextDecoration.none,
                            color: Colors.white))),
              )));
    }

}
