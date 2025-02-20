import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';

class RegisterButton extends StatelessWidget {
  const RegisterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<RegisterProvider>();

    return ElevatedButton(
      onPressed: bloc.registerParent,
      child: const Text('Registrar Padre'),
    );
  }
}
