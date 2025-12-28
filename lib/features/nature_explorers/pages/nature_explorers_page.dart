import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';
import 'package:edu_play/features/nature_explorers/bloc/nature_explorers_bloc.dart';
import 'package:edu_play/features/nature_explorers/pages/nature_explorers_layout.dart';
import 'package:edu_play/features/nature_explorers/repositories/nature_explorers_repository.dart';

class NatureExplorersPage extends StatelessWidget {
  const NatureExplorersPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtain age from RegisterProvider, default to 6 if not set or invalid
    final registerProvider = context.read<RegisterProvider>();
    int age = int.tryParse(registerProvider.age) ?? 6;

    return ChangeNotifierProvider<NatureExplorersProvider>(
      create: (context) => NatureExplorersProvider(
        context: context,
        age: age,
        repository: NatureExplorersRepository(),
      ),
      builder: (_, __) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFF9800), // Orange top
                Color(0xFFFFCC80), // Light Orange bottom
              ],
            ),
          ),
          child: const SafeArea(
            child: NatureExplorersLayout(),
          ),
        ),
      ),
    );
  }
}
