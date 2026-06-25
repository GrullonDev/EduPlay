import 'package:flutter/material.dart';
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

  Future<List<NatureItem>> getItems() async {
    final List<Map<String, dynamic>> maps =
        await _databaseHelper.getNatureItems();

    return List.generate(maps.length, (i) {
      final codePoint = maps[i]['icon_code_point'] as int;
      return NatureItem(
        name: maps[i]['name'],
        icon: _iconsMap[codePoint] ?? Icons.help_outline,
        color: Color(maps[i]['color_value']),
      );
    });
  }
}
