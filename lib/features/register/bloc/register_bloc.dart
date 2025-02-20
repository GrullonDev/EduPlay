import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:edu_play/utils/routes/router_paths.dart';

class RegisterProvider with ChangeNotifier {
  RegisterProvider({
    required this.context,
  }) {
    _usernameController = TextEditingController();
    _ageController = TextEditingController();
    _childNameController = TextEditingController();
    _childAgeController = TextEditingController();
  }

  final BuildContext context;
  late TextEditingController _usernameController;
  late TextEditingController _ageController;
  late TextEditingController _childNameController;
  late TextEditingController _childAgeController;

  TextEditingController get usernameController => _usernameController;
  TextEditingController get ageController => _ageController;
  TextEditingController get childNameController => _childNameController;
  TextEditingController get childAgeController => _childAgeController;

  String _age = '';
  bool _isSliderActive = false;
  int? _sliderValue;

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

  Future<void> registerParent() async {
    final userName = _usernameController.text;
    final age = _ageController.text;

    if (userName.isEmpty || age.isEmpty) {
      // Manejar el caso en que el nombre o la edad estén vacíos
      return;
    }

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email:
            'parent@example.com', // Reemplaza con el correo electrónico del padre
        password: 'password123', // Reemplaza con la contraseña del padre
      );

      await FirebaseFirestore.instance
          .collection('parents')
          .doc(userCredential.user!.uid)
          .set({
        'name': userName,
        'age': age,
        'children': [],
      });

      await Navigator.pushNamed(context, RouterPaths.registerChild);
    } catch (e) {
      // Manejar errores
      print(e);
    }
  }

  Future<void> registerChild() async {
    final childName = _childNameController.text;
    final childAge = _childAgeController.text;

    if (childName.isEmpty || childAge.isEmpty) {
      // Manejar el caso en que el nombre o la edad del niño estén vacíos
      return;
    }

    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentReference parentRef = FirebaseFirestore.instance
            .collection('parents')
            .doc(currentUser.uid);

        DocumentReference childRef =
            await FirebaseFirestore.instance.collection('children').add({
          'name': childName,
          'age': childAge,
          'parentId': currentUser.uid,
        });

        await parentRef.update({
          'children': FieldValue.arrayUnion([childRef.id]),
        });

        Navigator.pushNamed(context, RouterPaths.menu);
      }
    } catch (e) {
      // Manejar errores
      print(e);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _ageController.dispose();
    _childNameController.dispose();
    _childAgeController.dispose();
    super.dispose();
  }
}
