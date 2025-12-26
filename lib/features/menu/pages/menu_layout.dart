import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_play/features/menu/bloc/menu_bloc.dart';
import 'package:edu_play/features/menu/widgets/menu_buttons.dart';

class MenuLayout extends StatelessWidget {
  const MenuLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final double fontSize = context.read<MenuProvider>().getFontSize(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF3F5F9), // Light background
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola, Explorador!',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF2D3142),
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Elige tu próxima aventura:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: MenuButtons(fontSize: fontSize),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
