import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:edu_play/utils/routes/router_paths.dart';

class RegisterChildProvider with ChangeNotifier {
  RegisterChildProvider({
    required BuildContext context,
  }) : _context = context;

  final BuildContext _context;

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  String get name => nameController.text;
  String get age => ageController.text;

  Future<void> registerChild() async {
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('parents')
          .where('children', arrayContains: name)
          .get();

      if (result.docs.isNotEmpty) {
        // El niño ya está registrado como hijo de un padre
        Navigator.pushNamedAndRemoveUntil(
          _context,
          RouterPaths.menu,
          (route) => false,
          arguments: name,
        );
      } else {
        // Registrar al niño en la base de datos
        await FirebaseFirestore.instance.collection('children').add({
          'name': name,
          'age': age,
        });

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
