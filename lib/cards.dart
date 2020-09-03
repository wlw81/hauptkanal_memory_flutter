import 'package:flutter/material.dart';
import 'package:hauptkanal_memory/flags.dart';

class Cards extends StatelessWidget {
  final List<Image> _assets;
  final Function _cardTapped;

  Cards(this._cardTapped, this._assets);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
              height: 200,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: Flags.RANDOM_CARD_COUNT, itemBuilder: (BuildContext context, int position) {
                return InkWell(
                  onTap: _cardTapped(position),
                  child: Container(
                    width: 150,
                    child: Card(
                      elevation: 5,
                      child: _assets.elementAt(position),
                    ),
                  ),
                );
              }), )
        ]);
  }

}