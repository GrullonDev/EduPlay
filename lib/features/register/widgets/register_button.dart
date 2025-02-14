import 'package:flutter/material.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSizeButton = constraints.maxWidth > 600 ? 20 : 16;

        return ElevatedButton(
          onPressed: () {
            // TODO: Implement the action when the button is pressed
            // final username = context.read<RegisterProvider>().username;
            // Acción al presionar el botón con el username
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(20),
          ),
          child: Text(
            'Empezar a Jugar',
            style: TextStyle(
              fontSize: fontSizeButton,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
