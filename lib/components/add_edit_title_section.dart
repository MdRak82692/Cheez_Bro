import 'package:flutter/material.dart';
import '../utils/text.dart';

class AddEditTitleSection extends StatelessWidget {
  final String title;

  const AddEditTitleSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: style(24, color: Colors.black),
          ),
          const SizedBox(width: 410),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            label: Text(
              "Back",
              style: style(16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
