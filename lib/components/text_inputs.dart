import 'package:flutter/material.dart';
import 'package:listener13/utils/helper_widgets.dart';

import '../theme/theme_constants.dart';

Widget usernameTextInput(BuildContext context) {
  return Container(
      width: 373,
      height: 56,
      child: TextField(
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(color: COLOR_PRIMARY, width: 1)),
            filled: true,
            fillColor: COLOR_SECONDARY,
            hintText: 'Your username',
            hintStyle: TextStyle(
              color: COLOR_PRIMARY,
              fontSize: 16,
            )),
      ));
}

Widget passwordTextInput(BuildContext context) {
  return Container(
      width: 372,
      height: 56,
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(color: COLOR_PRIMARY, width: 1)),
            filled: true,
            fillColor: COLOR_SECONDARY,
            hintText: 'Your password',
            hintStyle: TextStyle(
              color: COLOR_PRIMARY,
              fontSize: 16,
            )),
      ));
}

Widget repeatPasswordTextInput(BuildContext context) {
  return Container(
      width: 372,
      height: 56,
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(color: COLOR_PRIMARY, width: 1)),
            filled: true,
            fillColor: COLOR_SECONDARY,
            hintText: 'Repeat your password',
            hintStyle: TextStyle(
              color: COLOR_PRIMARY,
              fontSize: 16,
            )),
      ));
}

Widget privateKeyTextInput(BuildContext context) {
  return Container(
      width: 373,
      height: 56,
      child: TextField(
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: const BorderSide(color: COLOR_PRIMARY, width: 1)),
            filled: true,
            fillColor: COLOR_SECONDARY,
            hintText: 'Your private key',
            hintStyle: TextStyle(
              color: COLOR_PRIMARY,
              fontSize: 16,
            )),
      ));
}
