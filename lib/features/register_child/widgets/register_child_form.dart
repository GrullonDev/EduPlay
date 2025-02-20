import 'package:flutter/material.dart';

class RegisterChildForm extends StatelessWidget {
  const RegisterChildForm({
    super.key,
    required this.nameController,
    required this.ageController,
  });

  final TextEditingController nameController;
  final TextEditingController ageController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nombre del Niño'),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: ageController,
            decoration: const InputDecoration(labelText: 'Edad del Niño'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
