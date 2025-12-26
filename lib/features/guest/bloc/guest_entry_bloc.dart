import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_play/data/datasources/local/database_helper.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

class GuestEntryProvider with ChangeNotifier {
  GuestEntryProvider({required this.context});

  final BuildContext context;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final TextEditingController nameController = TextEditingController();

  // Using an integer for age selection logic, or controller if text input
  // Let's use a simple integer selection for kids (Slider or Buttons)
  int _selectedAge = 6;
  int get selectedAge => _selectedAge;

  void setAge(int age) {
    _selectedAge = age;
    notifyListeners();
  }

  Future<void> enterAsGuest() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Por favor, dinos tu nombre!')),
      );
      return;
    }

    try {
      // 1. Save to Local DB (Skip on Web if not supported)
      try {
        await _dbHelper.insertChild(name, _selectedAge,
            avatar: 'default_guest');
      } catch (e) {
        // Just log and continue, don't block user if DB fails (e.g. on Web)
        debugPrint("Local DB skipped or failed: $e");
      }

      // 2. Update Global State for Game Difficulty
      if (context.mounted) {
        Provider.of<RegisterProvider>(context, listen: false)
            .setAge(_selectedAge.toString());
      }

      // 3. Navigate to Menu
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouterPaths.menu,
          (route) => false,
          arguments: name,
        );
      }
    } catch (e) {
      debugPrint("Error entering guest: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Ups! Algo salió mal.')),
        );
      }
    }
  }
}
