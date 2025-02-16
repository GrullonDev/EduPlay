import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_play/features/register/widgets/slider.dart';
import 'package:edu_play/features/register/widgets/register_button.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSizeTitle = constraints.maxWidth > 600 ? 34 : 24;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Regístrate',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSizeTitle,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Consumer<RegisterProvider>(
              builder: (context, provider, child) {
                return TextField(
                  controller: provider.usernameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre o Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelStyle:
                        const TextStyle(fontSize: 24, fontFamily: 'Istok Web'),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const SliderWidget(),
            const SizedBox(height: 20),
            const RegisterButton(),
          ],
        );
      },
    );
  }
}
