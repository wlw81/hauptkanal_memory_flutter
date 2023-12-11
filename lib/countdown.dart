import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hauptkanalmemory/flags.dart';

class Countdown extends StatelessWidget {
  int _secondsRemaining = Flags.COUNTDOWN_IN_SECONDS;

  Countdown(this._secondsRemaining);

  String _printDuration(Duration pDuration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(pDuration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(pDuration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Text(_printDuration(Duration(seconds: _secondsRemaining)),
        style: GoogleFonts.robotoCondensed(
            fontSize: 95,
            fontStyle: FontStyle.italic,
            textStyle: (_secondsRemaining > 10
                ? TextStyle(color: Colors.white54)
                : TextStyle(color: Colors.red[400]))));
  }
}
