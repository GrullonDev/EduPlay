// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:edu_play/data/datasources/local/database_helper.dart';
import 'package:edu_play/features/nature_explorers/bloc/nature_explorers_bloc.dart';

class NatureExplorersRepository {
  NatureExplorersRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();
  final DatabaseHelper _databaseHelper;

  static final Map<int, IconData> _iconsMap = {
    Icons.pets.codePoint: Icons.pets,
    Icons.forest.codePoint: Icons.forest,
    Icons.wb_sunny.codePoint: Icons.wb_sunny,
    Icons.cloud.codePoint: Icons.cloud,
    Icons.local_florist.codePoint: Icons.local_florist,
    Icons.landscape.codePoint: Icons.landscape,
    Icons.water_drop.codePoint: Icons.water_drop,
    Icons.local_fire_department.codePoint: Icons.local_fire_department,
    Icons.star.codePoint: Icons.star,
    Icons.nightlight_round.codePoint: Icons.nightlight_round,
    Icons.flutter_dash.codePoint: Icons.flutter_dash,
    Icons.set_meal.codePoint: Icons.set_meal,
  };

  /// Groups each item by conceptual category so the game can pick
  /// distractors that are *harder to tell apart* from the target as the
  /// level goes up (e.g. confusing "Sol" with "Luna" and "Estrella", all
  /// sky items) instead of only growing the grid size. The DB schema has
  /// no category column, so this is derived from the fixed seeded names.
  static const Map<String, String> _categoryByName = {
    'Sol': 'cielo',
    'Nube': 'cielo',
    'Estrella': 'cielo',
    'Luna': 'cielo',
    'Agua': 'elementos',
    'Fuego': 'elementos',
    'Árbol': 'naturaleza',
    'Flor': 'naturaleza',
    'Montaña': 'naturaleza',
    'León': 'animales',
    'Pájaro': 'animales',
    'Pez': 'animales',
  };

  /// A short, factual fact about each item, shown when the player picks
  /// the wrong icon so the mistake teaches something instead of just being
  /// marked wrong.
  static const Map<String, String> _explanationByName = {
    'León':
        'El león es un felino que vive en manadas llamadas "orgullos" y se alimenta de otros animales.',
    'Árbol':
        'Los árboles absorben dióxido de carbono y liberan gran parte del oxígeno que respiramos.',
    'Sol':
        'El Sol es la estrella más cercana a la Tierra: nos da luz y calor, y sin él no habría vida.',
    'Nube':
        'Las nubes están formadas por diminutas gotas de agua o cristales de hielo suspendidos en el aire.',
    'Flor':
        'Las flores producen semillas y atraen a insectos como las abejas para reproducirse.',
    'Montaña':
        'Las montañas se forman a lo largo de millones de años por el choque de placas de la corteza terrestre.',
    'Agua':
        'El agua cubre casi tres cuartas partes de la superficie de la Tierra.',
    'Fuego':
        'El fuego necesita oxígeno, calor y algo que arda (combustible) para mantenerse encendido.',
    'Estrella':
        'Las estrellas son enormes esferas de gas que producen su propia luz y calor.',
    'Luna':
        'La Luna gira alrededor de la Tierra y no produce luz propia: solo refleja la luz del Sol.',
    'Pájaro':
        'Las aves tienen plumas y huesos livianos que las ayudan a volar.',
    'Pez': 'Los peces respiran bajo el agua usando branquias, en lugar de pulmones.',
  };

  Future<List<NatureItem>> getItems() async {
    final List<Map<String, dynamic>> maps =
        await _databaseHelper.getNatureItems();

    return List.generate(maps.length, (i) {
      final codePoint = maps[i]['icon_code_point'] as int;
      final name = maps[i]['name'] as String;
      return NatureItem(
        name: name,
        icon: _iconsMap[codePoint] ?? Icons.help_outline,
        color: Color(maps[i]['color_value']),
        category: _categoryByName[name] ?? 'naturaleza',
        funFact: _explanationByName[name] ??
            'Este elemento forma parte de la naturaleza que nos rodea.',
      );
    });
  }
}
