import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_play/features/register_parents/bloc/register_parents_bloc.dart';

class RegisterParentsButton extends StatelessWidget {
  const RegisterParentsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSizeButton = constraints.maxWidth > 600 ? 20 : 16;

        return ElevatedButton(
          onPressed: () {
            context.read<RegisterParentsBloc>().registerParent();
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
