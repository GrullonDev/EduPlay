import 'package:flutter/material.dart';

class RegisterProvider with ChangeNotifier {
  RegisterProvider({required this.context});

  final BuildContext context;

  final TextEditingController _ageController = TextEditingController();

  String get age => _ageController.text;

  // Setter/methods if needed, but usage only suggests 'age' getter
  void setAge(String value) {
    _ageController.text = value;
    notifyListeners();
  }
}
