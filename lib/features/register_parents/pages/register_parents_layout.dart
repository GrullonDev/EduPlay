import 'package:edu_play/features/register_parents/widgets/register_parents_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_play/features/register_parents/bloc/register_parents_bloc.dart';
import 'package:edu_play/features/register_parents/widgets/register_parents_button.dart';
import 'package:edu_play/features/register_parents/widgets/register_parents_child_form.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

class RegisterParentsLayout extends StatelessWidget {
  const RegisterParentsLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterParentsBloc>(
      builder: (context, bloc, __) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
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
                  children: [
                    RegisterParentsForm(
                      emailController: bloc.emailController,
                      passwordController: bloc.passwordController,
                      firstNameController: bloc.firstNameController,
                      lastNameController: bloc.lastNameController,
                      ageController: bloc.ageController,
                    ),
                    const SizedBox(height: 20),
                    const RegisterParentsChildForm(),
                    const SizedBox(height: 20),
                    const RegisterParentsButton(),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                            context, RouterPaths.parentsDashboard);
                      },
                      icon: const Icon(Icons.dashboard_rounded),
                      label: const Text('Ver Progreso (Zona de Padres)'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
