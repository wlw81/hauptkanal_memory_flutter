import 'package:flutter/material.dart';
import 'package:hauptkanal_memory/flags.dart';
import 'dart:developer' as developer;

class Cards extends StatelessWidget {
  final List<Image> _assets;

  Cards(this._assets);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Expanded(
          child: SizedBox(
        height: 200,
        child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: Flags.RANDOM_CARD_COUNT,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                  child: Card(
                    elevation: 5,
                    child: _assets.elementAt(index),
                  ),
                onTap: () => Scaffold
                    .of(context)
                    .showSnackBar(SnackBar(content: Text(index.toString()))),
              );
            }),
      )),
    ]);
  }

  cardTapped(int position) {
    developer.log(position.toString());
  }
}
