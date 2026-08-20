// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/features/register_child/bloc/register_child_bloc.dart';
import 'package:edu_play/features/register_child/pages/register_child_layout.dart';
import 'package:edu_play/utils/injection_container.dart';

class RegisterChildPage extends StatelessWidget {
  const RegisterChildPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RegisterChildProvider>(
      create: (context) => RegisterChildProvider(
        context: context,
        repository: sl.get<AuthRepository>(),
      ),
      builder: (_, __) => Scaffold(
        appBar: AppBar(
          title: const Text('Registro de Niño'),
          centerTitle: true,
        ),
        body: const RegisterChildLayout(),
      ),
    );
  }
}
