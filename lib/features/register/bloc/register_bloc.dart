import 'package:edu_play/utils/routes/router_paths.dart';
import 'package:flutter/material.dart';

class RegisterProvider with ChangeNotifier {
  RegisterProvider({
    required this.context,
  }) {
    _usernameController = TextEditingController();
  }

  final BuildContext context;
  late TextEditingController _usernameController;

  String _age = '';
  bool _isSliderActive = false;
  int? _sliderValue;

  TextEditingController get usernameController => _usernameController;
  String get age => _age;
  bool get isSliderActive => _isSliderActive;
  int? get sliderValue => _sliderValue;

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
    final userName = usernameController.text;
    if (userName.isEmpty) {
      // Manejar el caso en que el nombre de usuario esté vacío
      return;
    }

    Navigator.pushNamedAndRemoveUntil(
      context,
      RouterPaths.menu,
      arguments: userName,
      (route) => false,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}
