import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edu_play/data/repositories/auth_repository.dart';
import 'package:edu_play/utils/routes/router_paths.dart';

class RegisterParentsBloc with ChangeNotifier {
  RegisterParentsBloc({
    required BuildContext context,
    required this.authRepository,
  })  : _context = context,
        mounted = true;

  final BuildContext _context;
  final bool mounted;
  final AuthRepository authRepository;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController childNameController = TextEditingController();
  TextEditingController childAgeController = TextEditingController();

  String get email => emailController.text;
  String get password => passwordController.text;
  String get firstName => firstNameController.text;
  String get lastName => lastNameController.text;
  String get age => ageController.text;
  final List<String> _children = [];

  List<String> get children => _children;

  void addChild(String child) {
    _children.add(child);
    notifyListeners();
  }

  void removeChild(String child) {
    _children.remove(child);
    notifyListeners();
  }

  Future<void> registerParent() async {
    User? user = await authRepository.registerParent(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      age: age,
      children: _children,
    );

    if (!mounted) return;

    if (user != null) {
      // Assuming parent also sets the child's age or context for the session?
      // Actually, parent registration goes to child registration, so maybe we don't set it here?
      // Wait, 'age' here refers to PARENT age. We don't want to set game difficulty based on parent age.
      // Skipping setAge here. Logic check: Parent enters THEIR age.
      Navigator.pushNamedAndRemoveUntil(
        _context,
        RouterPaths.registerChild,
        (route) => false,
      );
    } else {
      // Mostrar un mensaje de error
      showDialog(
        context: _context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('No se pudo registrar el usuario.'),
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

  void registerChild() {
    if (childNameController.text.isNotEmpty &&
        childAgeController.text.isNotEmpty) {
      addChild('${childNameController.text} (${childAgeController.text} años)');
      childNameController.clear();
      childAgeController.clear();
    }
  }
}
