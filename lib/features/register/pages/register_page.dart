import 'package:edu_play/features/register/bloc/register_bloc.dart';
import 'package:edu_play/features/register/pages/register_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterProvider>(
      create: (context) => RegisterProvider(context: context),
      builder: (_, __) => Scaffold(
        backgroundColor: Colors.greenAccent[200],
        body: const RegisterLayout(),
      ),
    );
  }
}
