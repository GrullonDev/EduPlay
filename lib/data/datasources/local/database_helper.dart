import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
  static final DatabaseHelper _instance = DatabaseHelper._internal();

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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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

    await db.execute('''
      CREATE TABLE challenges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        subject_key TEXT NOT NULL,
        due_date TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        created_at TEXT NOT NULL
      )
    ''');

    await _seedNatureItems(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS challenges (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          subject_key TEXT NOT NULL,
          due_date TEXT,
          status TEXT NOT NULL DEFAULT 'active',
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _seedNatureItems(Database db) async {
    final List<Map<String, dynamic>> items = [
      {
        'name': 'León',
        'icon_code_point': Icons.pets.codePoint,
        'color_value': Colors.orange.toARGB32()
      },
      {
        'name': 'Árbol',
        'icon_code_point': Icons.forest.codePoint,
        'color_value': Colors.green.toARGB32()
      },
      {
        'name': 'Sol',
        'icon_code_point': Icons.wb_sunny.codePoint,
        'color_value': Colors.yellow.toARGB32()
      },
      {
        'name': 'Nube',
        'icon_code_point': Icons.cloud.codePoint,
        'color_value': Colors.blue.toARGB32()
      },
      {
        'name': 'Flor',
        'icon_code_point': Icons.local_florist.codePoint,
        'color_value': Colors.pink.toARGB32()
      },
      {
        'name': 'Montaña',
        'icon_code_point': Icons.landscape.codePoint,
        'color_value': Colors.brown.toARGB32()
      },
      {
        'name': 'Agua',
        'icon_code_point': Icons.water_drop.codePoint,
        'color_value': Colors.blueAccent.toARGB32()
      },
      {
        'name': 'Fuego',
        'icon_code_point': Icons.local_fire_department.codePoint,
        'color_value': Colors.red.toARGB32()
      },
      {
        'name': 'Estrella',
        'icon_code_point': Icons.star.codePoint,
        'color_value': Colors.amber.toARGB32()
      },
      {
        'name': 'Luna',
        'icon_code_point': Icons.nightlight_round.codePoint,
        'color_value': Colors.indigo.toARGB32()
      },
      {
        'name': 'Pájaro',
        'icon_code_point': Icons.flutter_dash.codePoint,
        'color_value': Colors.teal.toARGB32()
      },
      {
        'name': 'Pez',
        'icon_code_point': Icons.set_meal.codePoint,
        'color_value': Colors.cyan.toARGB32()
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
    if (kIsWeb) {
      // Fallback: Web doesn't support persistence yet. Return dummy ID.
      debugPrint('Web: insertChild ignored (no persistence)');
      return 1;
    }
    final db = await database;
    return await db.insert('children', {
      'name': name,
      'age': age,
      'avatar': avatar,
    });
  }

  Future<List<Map<String, dynamic>>> getChildren() async {
    if (kIsWeb) {
      // Fallback: Return empty list or mock data
      debugPrint('Web: getChildren returning empty/mock list');
      return [];
    }
    final db = await database;
    return await db.query('children');
  }

  Future<int> insertScore(int childId, String gameType, int score) async {
    if (kIsWeb) return 1; // Fallback
    final db = await database;
    return await db.insert('scores', {
      'child_id': childId,
      'game_type': gameType,
      'score': score,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getScores(int childId) async {
    if (kIsWeb) return []; // Fallback
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
          'color_value': Colors.orange.toARGB32()
        },
        {
          'name': 'Árbol',
          'icon_code_point': Icons.forest.codePoint,
          'color_value': Colors.green.toARGB32()
        },
        {
          'name': 'Sol',
          'icon_code_point': Icons.wb_sunny.codePoint,
          'color_value': Colors.yellow.toARGB32()
        },
        {
          'name': 'Nube',
          'icon_code_point': Icons.cloud.codePoint,
          'color_value': Colors.blue.toARGB32()
        },
        {
          'name': 'Flor',
          'icon_code_point': Icons.local_florist.codePoint,
          'color_value': Colors.pink.toARGB32()
        },
        {
          'name': 'Montaña',
          'icon_code_point': Icons.landscape.codePoint,
          'color_value': Colors.brown.toARGB32()
        },
        {
          'name': 'Agua',
          'icon_code_point': Icons.water_drop.codePoint,
          'color_value': Colors.blueAccent.toARGB32()
        },
        {
          'name': 'Fuego',
          'icon_code_point': Icons.local_fire_department.codePoint,
          'color_value': Colors.red.toARGB32()
        },
        {
          'name': 'Estrella',
          'icon_code_point': Icons.star.codePoint,
          'color_value': Colors.amber.toARGB32()
        },
        {
          'name': 'Luna',
          'icon_code_point': Icons.nightlight_round.codePoint,
          'color_value': Colors.indigo.toARGB32()
        },
        {
          'name': 'Pájaro',
          'icon_code_point': Icons.flutter_dash.codePoint,
          'color_value': Colors.teal.toARGB32()
        },
        {
          'name': 'Pez',
          'icon_code_point': Icons.set_meal.codePoint,
          'color_value': Colors.cyan.toARGB32()
        },
      ];
    }
    final db = await database;
    return await db.query('nature_items');
  }

  // Challenges ("Retos Asignados" / "Misión del Día")
  //
  // Web doesn't support sqflite, so on web we keep an in-memory list that
  // lasts only for the current session.
  static final List<Map<String, dynamic>> _webChallenges = [];
  static int _webChallengeNextId = 1;

  Future<int> insertChallenge({
    required String title,
    required String subjectKey,
    String? dueDate,
  }) async {
    final challenge = {
      'title': title,
      'subject_key': subjectKey,
      'due_date': dueDate,
      'status': 'active',
      'created_at': DateTime.now().toIso8601String(),
    };

    if (kIsWeb) {
      final id = _webChallengeNextId++;
      _webChallenges.insert(0, {'id': id, ...challenge});
      return id;
    }

    final db = await database;
    return await db.insert('challenges', challenge);
  }

  Future<List<Map<String, dynamic>>> getChallenges() async {
    if (kIsWeb) {
      return List.unmodifiable(_webChallenges);
    }
    final db = await database;
    return await db.query('challenges', orderBy: 'created_at DESC');
  }

  Future<void> updateChallengeStatus(int id, String status) async {
    if (kIsWeb) {
      final challenge = _webChallenges.firstWhere(
        (c) => c['id'] == id,
        orElse: () => {},
      );
      challenge['status'] = status;
      return;
    }
    final db = await database;
    await db.update(
      'challenges',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Returns the count of active and completed challenges.
  Future<({int active, int completed})> getChallengeCounts() async {
    final challenges = await getChallenges();
    final active = challenges.where((c) => c['status'] == 'active').length;
    final completed =
        challenges.where((c) => c['status'] == 'completed').length;
    return (active: active, completed: completed);
  }
}
