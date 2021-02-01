import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:hauptkanalmemory/app_localizations.dart';

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
                  AppLocalizations.of(context).translate('introduction'), style: Theme
                  .of(context)
                  .textTheme
                  .bodyText1))
        ]),
      ),
      back: Card(
        color: Theme
            .of(context)
            .primaryColor,
        child: Padding(padding: const EdgeInsets.all(8.0),
            child: Text(
                AppLocalizations.of(context).translate('legal'), style: Theme
                .of(context)
                .textTheme
                .bodyText1)),
      ),
    );

  }

}