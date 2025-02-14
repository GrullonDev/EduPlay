import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:edu_play/features/menu/bloc/menu_bloc.dart';

class MenuButtons extends StatelessWidget {
  final double fontSize;

  const MenuButtons({
    super.key,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MenuProvider>();
    final games = bloc.games;

    return GridView.count(
      crossAxisCount: bloc.getCrossAxisCount(context),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: games.map(
        (game) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: game.color,
              padding: const EdgeInsets.all(16.0),
            ),
            onPressed: () {
              bloc.selectGame(game.title);
            },
            child: Text(
              game.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color:
                    game.color == Colors.yellow ? Colors.black : Colors.white,
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}
