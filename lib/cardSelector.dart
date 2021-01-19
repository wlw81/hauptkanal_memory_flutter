
import 'package:flutter/material.dart';
import 'package:hauptkanal_memory/gameCardItem.dart';

import 'flags.dart';

class CardSelector extends StatefulWidget {
  final List<Image> _nextRandomImages;
  final Function onTapped;

  const CardSelector( this._nextRandomImages, this.onTapped);

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<CardSelector> {

  @override
  Widget build(BuildContext context) {

    return Center(child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: Flags.RANDOM_CARD_COUNT,
        itemBuilder: (BuildContext context, int index) {
           return GestureDetector(
             onTap: () {
               widget.onTapped(index);
             },
            child: GameCardItem(widget._nextRandomImages.elementAt(index), index),
          );
        }));
  }


}
