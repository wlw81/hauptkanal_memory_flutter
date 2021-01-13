import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'flags.dart';

class Countdown extends StatefulWidget {

  final Function close;

  Countdown(this.close);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }


}

class _MyAppState extends State<Countdown> with TickerProviderStateMixin {

  Timer _timer;
  int _start = Flags.COUNTDOWN_IN_SECONDS;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (_timer == null || !_timer.isActive) {
      startTimer();
    }
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            try {
              timer.cancel();
            } finally {
              widget.close();
            }
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }


  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Text(_printDuration(Duration(seconds: _start)),
        style: GoogleFonts.robotoCondensed(
            fontSize: 95,
            fontStyle: FontStyle.italic,
            textStyle: TextStyle(color: Colors.white54)))
    ;
  }

}