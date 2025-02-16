import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/features/menu/bloc/menu_bloc.dart';
import 'package:edu_play/features/menu/widgets/menu_buttons.dart';

class MenuLayout extends StatelessWidget {
  const MenuLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final double fontSize = context.read<MenuProvider>().getFontSize(context);

    return Consumer<MenuProvider>(
      builder: (context, bloc, __) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nombre del jugador: ${bloc.username}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Seleccione un juego',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: MenuButtons(fontSize: fontSize),
            ),
          ],
        ),
      ),
    );
  }
}
