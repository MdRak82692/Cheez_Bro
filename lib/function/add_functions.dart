import 'package:flutter/material.dart';

void addFunction(BuildContext context, Widget targetWidget) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => targetWidget,
    ),
  );
}
