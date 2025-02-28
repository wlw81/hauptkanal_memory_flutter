// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "app_name": MessageLookupByLibrary.simpleMessage("Hauptkanal Shuffle"),
    "introduction": MessageLookupByLibrary.simpleMessage(
      "Can you reach the train station?\nTap on the next house and crack the high score!",
    ),
    "lastScore": MessageLookupByLibrary.simpleMessage("Last score"),
    "left2018": MessageLookupByLibrary.simpleMessage("Hauptkanal left 2018"),
    "left2022": MessageLookupByLibrary.simpleMessage(
      "Hauptkanal left 2022 (at night)",
    ),
    "legal": MessageLookupByLibrary.simpleMessage(
      "Coding & design: Thomas Pasligh (2022 photos: Philip Schöppe, QA: klokodax, music by Mrthenoronha)\n\nAll displayed image copyright remains by its respective owners.",
    ),
    "right2018": MessageLookupByLibrary.simpleMessage("Hauptkanal right 2018"),
    "right2022": MessageLookupByLibrary.simpleMessage(
      "Hauptkanal right 2022  (at night)",
    ),
    "score": MessageLookupByLibrary.simpleMessage("Score"),
    "scoreboard": MessageLookupByLibrary.simpleMessage("Leaderboard"),
    "selectStreet": MessageLookupByLibrary.simpleMessage("Select a street"),
  };
}
