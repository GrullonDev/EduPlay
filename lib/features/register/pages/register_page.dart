import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';
import 'package:edu_play/features/register/widgets/register_form.dart';
import 'package:edu_play/utils/injection_container.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterProvider>(
      create: (context) => RegisterProvider(
        context: context,
        authRepository: sl.get<AuthRepository>(),
      ),
      builder: (_, __) => Scaffold(
        appBar: AppBar(
          title: const Text('Registro de Padres'),
          centerTitle: true,
        ),
        body: const RegisterForm(),
      ),
    );
  }
}
