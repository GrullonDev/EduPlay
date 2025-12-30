import 'package:flutter/material.dart';

import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/data/datasources/local/database_helper.dart';
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

  String _selectedAvatar = 'lion'; // Default
  String get selectedAvatar => _selectedAvatar;

  void selectAvatar(String avatar) {
    _selectedAvatar = avatar;
    notifyListeners();
  }

  void setAge(int age) {
    ageController.text = age.toString();
    notifyListeners();
  }

  Future<void> registerChild() async {
    try {
      final bool isRegistered = await _repository.isChildRegistered(name);

      if (isRegistered) {
        // El niño ya está registrado como hijo de un padre
        if (!_context.mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          _context,
          RouterPaths.menu,
          (route) => false,
          arguments: name,
        );
      } else {
        // Registrar al niño en la base de datos
        await _repository.registerChild(name, age);

        // Save to Local DB (Offline support)
        try {
          final dbHelper = DatabaseHelper();
          // Try parse age to int, default to 6 if fail
          int ageInt = int.tryParse(age) ?? 6;
          await dbHelper.insertChild(name, ageInt, avatar: _selectedAvatar);
        } catch (e) {
          debugPrint("Local DB Error: $e");
        }

        // Update Global Age in RegisterProvider
        if (!_context.mounted) return;
        Provider.of<RegisterProvider>(_context, listen: false).setAge(age);

        if (!_context.mounted) return;
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
