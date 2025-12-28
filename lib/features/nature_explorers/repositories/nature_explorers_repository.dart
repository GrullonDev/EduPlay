import 'package:flutter/material.dart';
import 'package:edu_play/data/datasources/local/database_helper.dart';
import 'package:edu_play/features/nature_explorers/bloc/nature_explorers_bloc.dart';

class NatureExplorersRepository {
  final DatabaseHelper _databaseHelper;

  NatureExplorersRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  Future<List<NatureItem>> getItems() async {
    final List<Map<String, dynamic>> maps =
        await _databaseHelper.getNatureItems();

    return List.generate(maps.length, (i) {
      return NatureItem(
        name: maps[i]['name'],
        icon: IconData(maps[i]['icon_code_point'], fontFamily: 'MaterialIcons'),
        color: Color(maps[i]['color_value']),
      );
    });
  }
}
