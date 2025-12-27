import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // 1. WEB SUPPORT: Sqflite doesn't work on Web by default without additional setup.
    // For now, on Web, we will simply NOT initialize the DB to avoid crashes.
    // In a real app, we'd use 'sqflite_common_ffi_web' or drift.
    if (kIsWeb) {
      throw UnsupportedError('Local Database not supported on Web yet');
    }

    // 2. DESKTOP SUPPORT (Windows/Linux/Mac)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'eduplay.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE children (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        avatar TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        child_id INTEGER,
        game_type TEXT,
        score INTEGER,
        date TEXT,
        FOREIGN KEY (child_id) REFERENCES children (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE nature_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_code_point INTEGER NOT NULL,
        color_value INTEGER NOT NULL
      )
    ''');

    await _seedNatureItems(db);
  }

  Future<void> _seedNatureItems(Database db) async {
    final List<Map<String, dynamic>> items = [
      {
        'name': 'León',
        'icon_code_point': Icons.pets.codePoint,
        'color_value': Colors.orange.value
      },
      {
        'name': 'Árbol',
        'icon_code_point': Icons.forest.codePoint,
        'color_value': Colors.green.value
      },
      {
        'name': 'Sol',
        'icon_code_point': Icons.wb_sunny.codePoint,
        'color_value': Colors.yellow.value
      },
      {
        'name': 'Nube',
        'icon_code_point': Icons.cloud.codePoint,
        'color_value': Colors.blue.value
      },
      {
        'name': 'Flor',
        'icon_code_point': Icons.local_florist.codePoint,
        'color_value': Colors.pink.value
      },
      {
        'name': 'Montaña',
        'icon_code_point': Icons.landscape.codePoint,
        'color_value': Colors.brown.value
      },
      {
        'name': 'Agua',
        'icon_code_point': Icons.water_drop.codePoint,
        'color_value': Colors.blueAccent.value
      },
      {
        'name': 'Fuego',
        'icon_code_point': Icons.local_fire_department.codePoint,
        'color_value': Colors.red.value
      },
      {
        'name': 'Estrella',
        'icon_code_point': Icons.star.codePoint,
        'color_value': Colors.amber.value
      },
      {
        'name': 'Luna',
        'icon_code_point': Icons.nightlight_round.codePoint,
        'color_value': Colors.indigo.value
      },
      {
        'name': 'Pájaro',
        'icon_code_point': Icons.flutter_dash.codePoint,
        'color_value': Colors.teal.value
      },
      {
        'name': 'Pez',
        'icon_code_point': Icons.set_meal.codePoint,
        'color_value': Colors.cyan.value
      },
    ];

    final batch = db.batch();
    for (var item in items) {
      batch.insert('nature_items', item);
    }
    await batch.commit();
  }

  // CRUD Operations

  Future<int> insertChild(String name, int age, {String? avatar}) async {
    final db = await database;
    return await db.insert('children', {
      'name': name,
      'age': age,
      'avatar': avatar,
    });
  }

  Future<List<Map<String, dynamic>>> getChildren() async {
    final db = await database;
    return await db.query('children');
  }

  Future<int> insertScore(int childId, String gameType, int score) async {
    final db = await database;
    return await db.insert('scores', {
      'child_id': childId,
      'game_type': gameType,
      'score': score,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getScores(int childId) async {
    final db = await database;
    return await db.query(
      'scores',
      where: 'child_id = ?',
      whereArgs: [childId],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getNatureItems() async {
    if (kIsWeb) {
      // Fallback for Web: Return static data mimicking the DB structure
      return [
        {
          'name': 'León',
          'icon_code_point': Icons.pets.codePoint,
          'color_value': Colors.orange.value
        },
        {
          'name': 'Árbol',
          'icon_code_point': Icons.forest.codePoint,
          'color_value': Colors.green.value
        },
        {
          'name': 'Sol',
          'icon_code_point': Icons.wb_sunny.codePoint,
          'color_value': Colors.yellow.value
        },
        {
          'name': 'Nube',
          'icon_code_point': Icons.cloud.codePoint,
          'color_value': Colors.blue.value
        },
        {
          'name': 'Flor',
          'icon_code_point': Icons.local_florist.codePoint,
          'color_value': Colors.pink.value
        },
        {
          'name': 'Montaña',
          'icon_code_point': Icons.landscape.codePoint,
          'color_value': Colors.brown.value
        },
        {
          'name': 'Agua',
          'icon_code_point': Icons.water_drop.codePoint,
          'color_value': Colors.blueAccent.value
        },
        {
          'name': 'Fuego',
          'icon_code_point': Icons.local_fire_department.codePoint,
          'color_value': Colors.red.value
        },
        {
          'name': 'Estrella',
          'icon_code_point': Icons.star.codePoint,
          'color_value': Colors.amber.value
        },
        {
          'name': 'Luna',
          'icon_code_point': Icons.nightlight_round.codePoint,
          'color_value': Colors.indigo.value
        },
        {
          'name': 'Pájaro',
          'icon_code_point': Icons.flutter_dash.codePoint,
          'color_value': Colors.teal.value
        },
        {
          'name': 'Pez',
          'icon_code_point': Icons.set_meal.codePoint,
          'color_value': Colors.cyan.value
        },
      ];
    }
    final db = await database;
    return await db.query('nature_items');
  }
}
