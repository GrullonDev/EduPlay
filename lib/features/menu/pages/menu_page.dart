import 'package:edu_play/features/menu/bloc/menu_bloc.dart';
import 'package:edu_play/features/register/bloc/register_bloc.dart';
import 'package:flutter/material.dart';
import 'package:edu_play/features/menu/pages/menu_layout.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({
    super.key,
    required this.username,
  });

  final String? username;

  @override
  Widget build(BuildContext context) {
    // Obtain age from RegisterProvider, default to 6 if not set or invalid
    final registerProvider = context.read<RegisterProvider>();
    int age = int.tryParse(registerProvider.age) ?? 6;

    return ChangeNotifierProvider<MenuProvider>(
      create: (context) => MenuProvider(
        context: context,
        age: age,
      , username: username),
      builder: (_, __) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Bienvenido a EduPlay',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 37,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: const MenuLayout(),
      ),
    );
  }
}
