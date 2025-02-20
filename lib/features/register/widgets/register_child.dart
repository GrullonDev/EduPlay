import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';

class RegisterChild extends StatelessWidget {
  const RegisterChild({super.key});

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
              controller: context.read<RegisterProvider>().childNameController,
              decoration: const InputDecoration(labelText: 'Nombre del Niño'),
            ),
            TextField(
              controller: context.read<RegisterProvider>().childAgeController,
              decoration: const InputDecoration(labelText: 'Edad del Niño'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                context.read<RegisterProvider>().registerChild();
              },
              child: const Text('Registrar Niño'),
            ),
          ],
        ),
      ),
    );
  }
}
