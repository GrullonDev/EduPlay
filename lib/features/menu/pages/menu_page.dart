import 'package:edu_play/features/menu/bloc/menu_bloc.dart';
import 'package:flutter/material.dart';
import 'package:edu_play/features/menu/pages/menu_layout.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MenuProvider>(
      create: (context) => MenuProvider(context: context),
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
