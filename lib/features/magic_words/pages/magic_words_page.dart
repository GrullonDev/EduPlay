import 'package:edu_play/features/magic_words/bloc/magic_words_bloc.dart';
import 'package:edu_play/features/magic_words/pages/magic_words_layout.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MagicWordsPage extends StatelessWidget {
  const MagicWordsPage({super.key, this.onScoreUpdate});

  final void Function(int score)? onScoreUpdate;

  @override
  Widget build(BuildContext context) {
    // Obtain age from RegisterProvider
    final registerProvider = context.read<RegisterProvider>();
    int age = int.tryParse(registerProvider.age) ?? 6;

    return ChangeNotifierProvider<MagicWordsProvider>(
      create: (context) => MagicWordsProvider(
        context: context,
        age: age,
        onScoreUpdate: onScoreUpdate,
      ),
      builder: (_, __) => Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF16125C), // Deep navy
                Color(0xFF231B72), // Mid navy
                Color(0xFF12104A), // Darker navy
              ],
              stops: [0.0, 0.55, 1.0],
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
