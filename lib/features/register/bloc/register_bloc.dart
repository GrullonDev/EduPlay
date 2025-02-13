import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:flutter/material.dart';

class RegisterProvider with ChangeNotifier {
  RegisterProvider({
    required this.context,
  });

  BuildContext context;

  String _username = '';
  String _age = '';
  bool _isSliderActive = false;
  int? _sliderValue;

  String get username => _username;
  String get age => _age;
  bool get isSliderActive => _isSliderActive;
  int? get sliderValue => _sliderValue;

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void toggleSlider(bool isActive) {
    _isSliderActive = isActive;
    notifyListeners();
  }

  void setSliderValue(int value) {
    _sliderValue = value;
    _age = value.toString();
    notifyListeners();
  }

  void registerUser() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouterPaths.menu,
      (route) => false, // Reemplaza todas las pantallas anteriores
    );
  }
}
