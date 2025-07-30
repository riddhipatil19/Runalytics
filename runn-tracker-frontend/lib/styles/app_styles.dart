import 'package:flutter/material.dart';

class AppStyles {
  static TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static InputDecoration inputDecoration(String text) => InputDecoration(
    labelText: text,
    labelStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.w400),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 1.0),
    ),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.blue, width: 1.0),
    ),
  );
}
