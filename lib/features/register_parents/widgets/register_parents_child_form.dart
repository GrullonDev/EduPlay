import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/features/register_parents/bloc/register_parents_bloc.dart';

class RegisterParentsChildForm extends StatelessWidget {
  const RegisterParentsChildForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterParentsBloc>(
      builder: (context, bloc, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller: bloc.childNameController,
            decoration: const InputDecoration(labelText: 'Nombre del Niño'),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: bloc.childAgeController,
            decoration: const InputDecoration(labelText: 'Edad del Niño'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              bloc.registerChild();
            },
            child: const Text('Registrar Niño'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Niños registrados:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...bloc.children.map((child) => Text(child)),
        ],
      ),
    );
  }
}
