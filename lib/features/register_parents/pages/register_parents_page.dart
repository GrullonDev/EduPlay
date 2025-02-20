import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/features/register_parents/bloc/register_parents_bloc.dart';
import 'package:edu_play/features/register_parents/pages/register_parents_layout.dart';
import 'package:edu_play/utils/injection_container.dart';

class RegisterParentsPage extends StatelessWidget {
  const RegisterParentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterParentsBloc>(
      create: (context) => RegisterParentsBloc(
        context: context,
        authRepository: sl.get<AuthRepository>(),
      ),
      builder: (_, __) => Scaffold(
        appBar: AppBar(
          title: const Text('Registro de Padres'),
          centerTitle: true,
        ),
        body: const RegisterParentsLayout(),
      ),
    );
  }
}
