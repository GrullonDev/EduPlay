import 'package:flutter/material.dart';

import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';
import 'package:provider/provider.dart';

class RegisterChildProvider with ChangeNotifier {
  RegisterChildProvider({
    required BuildContext context,
    required AuthRepository repository,
  })  : _context = context,
        _repository = repository;

  final BuildContext _context;
  final AuthRepository _repository;

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  String get name => nameController.text;
  String get age => ageController.text;

  Future<void> registerChild() async {
    try {
      final bool isRegistered = await _repository.isChildRegistered(name);

      if (isRegistered) {
        // El niño ya está registrado como hijo de un padre
        Navigator.pushNamedAndRemoveUntil(
          _context,
          RouterPaths.menu,
          (route) => false,
          arguments: name,
        );
      } else {
        // Registrar al niño en la base de datos
        await _repository.registerChild(name, age);

        // Update Global Age in RegisterProvider
        Provider.of<RegisterProvider>(_context, listen: false).setAge(age);

        Navigator.pushNamedAndRemoveUntil(
          _context,
          RouterPaths.menu,
          (route) => false,
          arguments: name,
        );
      }
    } catch (e) {
      // Mostrar un mensaje de error
      showDialog(
        context: _context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('No se pudo registrar el niño.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }
}
