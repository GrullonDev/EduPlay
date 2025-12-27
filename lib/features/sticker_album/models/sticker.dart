import 'package:flutter/material.dart';

class Sticker {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String description;

  const Sticker({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
  });
}

// Static list of all available stickers
final List<Sticker> allStickers = [
  const Sticker(
      id: 'dino',
      name: 'Dino Rex',
      icon: Icons.pets,
      color: Colors.green,
      description: 'Rey de los dinos'),
  const Sticker(
      id: 'rocket',
      name: 'Cohete Veloz',
      icon: Icons.rocket_launch,
      color: Colors.red,
      description: 'Viaja a las estrellas'),
  const Sticker(
      id: 'treasure',
      name: 'Cofre de Oro',
      icon: Icons.inventory_2,
      color: Colors.amber,
      description: '¡Riquezas piratas!'),
  const Sticker(
      id: 'star',
      name: 'Super Estrella',
      icon: Icons.star,
      color: Colors.yellow,
      description: 'Brillas mucho'),
  const Sticker(
      id: 'music',
      name: 'Nota Musical',
      icon: Icons.music_note,
      color: Colors.blue,
      description: 'Do Re Mi Fa Sol'),
  const Sticker(
      id: 'ball',
      name: 'Balón de Oro',
      icon: Icons.sports_soccer,
      color: Colors.white,
      description: 'Goleador nato'),
  const Sticker(
      id: 'painter',
      name: 'Pincel Mágico',
      icon: Icons.brush,
      color: Colors.purple,
      description: 'Artista creativo'),
  const Sticker(
      id: 'book',
      name: 'Libro Sabio',
      icon: Icons.menu_book,
      color: Colors.brown,
      description: 'Lector experto'),
];
