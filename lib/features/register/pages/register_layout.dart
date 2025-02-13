import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/features/register/bloc/register_bloc.dart';
import 'package:edu_play/features/register/widgets/slider_control.dart';
import 'package:edu_play/features/register/widgets/slider_text.dart';

class RegisterLayout extends StatelessWidget {
  const RegisterLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterProvider>(
      builder: (context, bloc, __) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: 'Username'),
                    onChanged: (value) => bloc.setUsername(value),
                  ),
                  const SizedBox(height: 20),
                  const SliderText(),
                  const SizedBox(height: 20),
                  const SliderControl(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: bloc.registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text(
                      'Empezar a jugar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
