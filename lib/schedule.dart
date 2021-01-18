import 'dart:async';

import 'package:flutter/material.dart';


class MySchedule extends ChangeNotifier  {

  int _secondsRemaining;
  Timer _timer;

  int get secondsRemaining => _secondsRemaining;

  void setSecondsRemaining(int pSeconds){
    _secondsRemaining = pSeconds;
    notifyListeners();
  }

}
