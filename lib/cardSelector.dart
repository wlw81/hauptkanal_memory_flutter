import 'package:flutter/material.dart';
import 'package:hauptkanalmemory/gameCardItem.dart';

import 'flags.dart';

class CardSelector extends StatelessWidget {
  final List<Image> _nextRandomImages;
  final Function onTapped;

  const CardSelector(this._nextRandomImages, this.onTapped);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: Flags.RANDOM_CARD_COUNT,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  onTapped(index);
                },
                child: GameCardItem(_nextRandomImages.elementAt(index), index),
              );
            }));
  }
}
