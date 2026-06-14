import 'dart:math';
import 'package:flutter/material.dart';

class ChildProfile {
  factory ChildProfile.fromJson(Map<String, dynamic> j) => ChildProfile(
        id: j['id'] as String,
        name: j['name'] as String,
        age: j['age'] as int,
        level: j['level'] as int,
        pin: j['pin'] as String,
        focusSubject: j['focusSubject'] as String,
        levelProgress: (j['levelProgress'] as num).toDouble(),
        avatarColorHex: j['avatarColorHex'] as String,
        isOnline: j['isOnline'] as bool? ?? false,
        lastSeen: j['lastSeen'] as String? ?? 'Hace un momento',
      );
  const ChildProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.level,
    required this.pin,
    required this.focusSubject,
    required this.levelProgress,
    required this.avatarColorHex,
    this.isOnline = false,
    this.lastSeen = 'Hace un momento',
  });

  final String id;
  final String name;
  final int age;
  final int level;
  final String pin; // 4-digit string
  final String focusSubject;
  final double levelProgress; // 0–1
  final String avatarColorHex;
  final bool isOnline;
  final String lastSeen;

  Color get avatarColor => Color(int.parse('0xFF$avatarColorHex'));

  String get levelLabel => 'Nivel ${level.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'level': level,
        'pin': pin,
        'focusSubject': focusSubject,
        'levelProgress': levelProgress,
        'avatarColorHex': avatarColorHex,
        'isOnline': isOnline,
        'lastSeen': lastSeen,
      };

  ChildProfile copyWith({
    String? name,
    int? age,
    int? level,
    String? pin,
    String? focusSubject,
    double? levelProgress,
    String? avatarColorHex,
    bool? isOnline,
    String? lastSeen,
  }) =>
      ChildProfile(
        id: id,
        name: name ?? this.name,
        age: age ?? this.age,
        level: level ?? this.level,
        pin: pin ?? this.pin,
        focusSubject: focusSubject ?? this.focusSubject,
        levelProgress: levelProgress ?? this.levelProgress,
        avatarColorHex: avatarColorHex ?? this.avatarColorHex,
        isOnline: isOnline ?? this.isOnline,
        lastSeen: lastSeen ?? this.lastSeen,
      );

  /// Generates a random 4-digit PIN string.
  static String generatePin() {
    final rng = Random();
    return List.generate(4, (_) => rng.nextInt(10)).join();
  }

  /// Default avatar colors (cycling).
  static const _avatarColors = [
    'E67E22', // Orange
    '9B59B6', // Purple
    '2ECC71', // Green
    '3498DB', // Blue
    'E91E63', // Pink
    '1ABC9C', // Teal
  ];

  static String avatarColorForIndex(int index) =>
      _avatarColors[index % _avatarColors.length];
}
