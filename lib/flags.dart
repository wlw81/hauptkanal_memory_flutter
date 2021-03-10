

import 'package:flutter/cupertino.dart';

class Flags {
  static const STREET_RIGHT = "hauptkanalRechts";
  static const STREET_LEFT = "hauptkanalLinks";
  static const ACHV_WELCOME = "CgkIwu3zjrEQEAIQAQ";
  static const ACHV_FIRSTRUN = "CgkIwu3zjrEQEAIQBQ";
  static final LEADERBORD_LEFT = HighScoreList("CgkIwu3zjrEQEAIQAw", "hauptkanal_left_2018");
  static final LEADERBORD_RIGHT = HighScoreList("CgkIwu3zjrEQEAIQBA", "hauptkanal_right_2018");
  static const STREET = "SEITE";
  static const LOG = "HAUPTKANAL";
  static const COUNTDOWN_IN_SECONDS = 90;
  static const DELAY = 600;
  static const RANDOM_IMAGES = 2;
  static const RC_SIGN_IN = 42;
  static const ACHIEVMENT = "CgkIprKIoKsaEAIQAg";
  static const RANDOM_CARD_COUNT = 3;
}

class HighScoreList {
  final String androidID;
  final String iOSID;

  HighScoreList(this.androidID, this.iOSID);
}