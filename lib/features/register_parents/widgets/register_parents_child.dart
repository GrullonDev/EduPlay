import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_play/features/register_parents/bloc/register_parents_bloc.dart';

class RegisterParentsChild extends StatelessWidget {
  const RegisterParentsChild({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Hijos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller:
                  context.read<RegisterParentsBloc>().childNameController,
              decoration: const InputDecoration(labelText: 'Nombre del Niño'),
            ),
            TextField(
              controller:
                  context.read<RegisterParentsBloc>().childAgeController,
              decoration: const InputDecoration(labelText: 'Edad del Niño'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                context.read<RegisterParentsBloc>().registerChild();
              },
              child: const Text('Registrar Niño'),
            ),
          ],
        ),
      ),
    );
  }
}
