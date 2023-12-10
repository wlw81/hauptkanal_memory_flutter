import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WelcomeFlip extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL, // default
      front: Card(
        color: Theme
            .of(context)
            .primaryColor,
        child: Column(children: <Widget>[
          Padding(padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/pbglion.png', scale: 5,),),
          Padding(padding: const EdgeInsets.all(8.0),
              child: Text(
                  AppLocalizations.of(context)!.introduction, style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge))
        ]),
      ),
      back: Card(
        color: Theme
            .of(context)
            .primaryColor,
        child: Padding(padding: const EdgeInsets.all(8.0),
            child: Text(
                AppLocalizations.of(context)!.legal, style: Theme
                .of(context)
                .textTheme
                .bodyLarge)),
      ),
    );

  }

}