import 'package:flutter/material.dart';
import '../utils/text.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final String text;

  const CustomButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text, style: style(18, color: Colors.black)),
      ),
    );
  }
}
