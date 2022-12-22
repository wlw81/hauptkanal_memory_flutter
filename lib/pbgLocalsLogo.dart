import 'package:flutter/material.dart';

class PbgLocalsLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text('supported by', style: Theme.of(context).textTheme.bodySmall.copyWith(color: Theme.of(context).primaryColor),),
          Image.asset('assets/pbgLocals.png', width: 64, height: 64,)
        ],
      ),
    );
  }

}