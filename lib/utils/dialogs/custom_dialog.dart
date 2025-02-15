import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: onButtonPressed,
          child: Text(buttonText),
        ),
      ],
    );
  }
}
