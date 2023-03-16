// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:listener13/theme/theme_constants.dart';

@override
Widget audioPlayer(BuildContext context) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.start,

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bohemian Rhapsody",
              style: TextStyle(
                  color: COLOR_SECONDARY,
                  fontSize: 19,
                  fontWeight: FontWeight.bold)),
          Text("Queen".toUpperCase(),
              style: TextStyle(
                color: Color(0xFFA5C0FF).withOpacity(0.7),
                fontSize: 11,
              )),
        ],
      ),
    ),
    Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: null,
            iconSize: 35,
            icon: Icon(
              Icons.skip_previous,
              color: COLOR_SECONDARY,
            ),
          ),
          IconButton(
            onPressed: null,
            iconSize: 35,
            icon: Icon(
              Icons.play_arrow,
              color: COLOR_SECONDARY,
            ),
          ),
          IconButton(
            onPressed: null,
            iconSize: 35,
            icon: Icon(
              Icons.skip_next,
              color: COLOR_SECONDARY,
            ),
          )
        ],
      ),
    ),
  ]);
}
