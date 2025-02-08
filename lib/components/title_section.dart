import 'package:flutter/material.dart';
import '../function/add_functions.dart';
import '../utils/text.dart';

class TitleSection extends StatelessWidget {
  final String title;
  final Widget? targetWidget;
  final bool addIcon;

  const TitleSection({
    super.key,
    required this.title,
    this.targetWidget,
    required this.addIcon,
  }) : assert(
          addIcon == false || targetWidget != null,
          'targetWidget must not be null if addIcon is true',
        );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: style(24, color: Colors.black),
          ),
          if (addIcon && targetWidget != null)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.green),
              onPressed: () => addFunction(context, targetWidget!),
            ),
        ],
      ),
    );
  }
}
