import 'package:edu_play/features/magic_words/bloc/magic_words_bloc.dart';
import 'package:edu_play/features/magic_words/pages/magic_words_layout.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MagicWordsPage extends StatelessWidget {
  const MagicWordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtain age from RegisterProvider
    final registerProvider = context.read<RegisterProvider>();
    int age = int.tryParse(registerProvider.age) ?? 6;

    return ChangeNotifierProvider<MagicWordsProvider>(
      create: (context) => MagicWordsProvider(
        context: context,
        age: age,
      ),
      builder: (_, __) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2196F3), // Bright Blue
                Color(0xFF64B5F6), // Lighter Blue
              ],
            ),
          ),
          child: const SafeArea(
            child: MagicWordsLayout(),
          ),
        ),
      ),
    );
  }
}
