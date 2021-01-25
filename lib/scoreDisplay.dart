
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hauptkanalmemory/app_localizations.dart';
import "package:intl/intl.dart";

class ScoreDisplay extends StatelessWidget {

  final bool currentGame;
  final int _value;

  ScoreDisplay(this._value, this.currentGame);

  NumberFormat _format = NumberFormat('###,###,000', 'de_DE');


  @override
  Widget build(BuildContext context) {
    if(currentGame){
      return Container(
          alignment: Alignment.topRight,
          padding: EdgeInsets.all(25.0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Text(
                  AppLocalizations.of(context).translate('score') +
                      ' ' + _format.format(_value),
                  style: GoogleFonts.robotoCondensed(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      textStyle: TextStyle(
                          backgroundColor: Theme.of(context).primaryColor,
                          color: Colors.white)))));
    }else{
      return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(25.0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: Text(
                  AppLocalizations.of(context).translate('lastScore') +
                      ' ' + _format.format(_value),
                  style: GoogleFonts.robotoCondensed(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      textStyle: TextStyle(
                          color: Colors.purple)))));
    }
  }

}
