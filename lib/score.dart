
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hauptkanal_memory/app_localizations.dart';

class Score extends StatelessWidget {

  final int _value;

  Score(this._value);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.topRight,
        padding: EdgeInsets.all(25.0),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Text(
                AppLocalizations.of(context).translate('score') +
                ' ' + _value.toString(),
                style: GoogleFonts.roboto(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    textStyle: TextStyle(
                        backgroundColor: Colors.purple,
                        color: Colors.white)))));
  }

}
