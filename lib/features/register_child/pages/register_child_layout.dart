import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/features/register_child/bloc/register_child_bloc.dart';
import 'package:edu_play/features/register_child/widgets/register_child_form.dart';
import 'package:edu_play/features/register_child/widgets/save_button.dart';

class RegisterChildLayout extends StatelessWidget {
  const RegisterChildLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterChildProvider>(
      builder: (context, bloc, __) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RegisterChildForm(
              nameController: bloc.nameController,
              ageController: bloc.ageController,
            ),
            const SizedBox(height: 20),
            SaveButton(
              onPressed: bloc.registerChild,
            ),
          ],
        ),
      ),
    );
  }
}
