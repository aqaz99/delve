import 'package:delve/Ability/ability.dart';
import 'package:delve/Ability/ability_list.dart';
import 'dart:math';

import 'package:delve/Character/character_list.dart';

class Character {
  final String name;
  int maxHealth;
  int currentHealth;
  int speed;
  List<Ability> abilities;
  bool currentlyDelving;

  // Leveling and EXP
  static const double _xpExponent = 1.5;
  static const int _baseXP = 100;
  static const double _healthMultiplier = 1.1;
  int level = 1;
  int currentXP = 0;
  int totalKills = 0;
  int expValue = 0;

  int get nextLevelXP => (_baseXP * pow(level, _xpExponent)).round();
  bool get isAlive => currentHealth > 0;

  Character({
    required this.name,
    required this.maxHealth,
    required this.speed,
    required this.abilities,
    required this.currentlyDelving,
    required this.level,
    required this.currentXP,
    required this.totalKills,
    int? currentHealth,
  }) : currentHealth = currentHealth ?? maxHealth;

  Character.copy(Character other)
    : name = other.name,
      maxHealth = other.maxHealth,
      currentHealth = other.currentHealth,
      speed = other.speed,
      currentlyDelving = other.currentlyDelving,
      abilities = List.from(other.abilities),
      level = other.level;

  Character copyWith({
    String? name,
    int? maxHealth,
    int? currentHealth,
    int? speed,
    List<Ability>? abilities,
    bool? currentlyDelving,
    int? level,
    int? currentXP,
    int? totalKills,
  }) {
    return Character(
      name: name ?? this.name,
      maxHealth: maxHealth ?? this.maxHealth,
      currentHealth: currentHealth ?? this.currentHealth,
      speed: speed ?? this.speed,
      abilities: abilities ?? List.from(this.abilities),
      currentlyDelving: currentlyDelving ?? this.currentlyDelving,
      level: level ?? this.level,
      currentXP: currentXP ?? this.currentXP,
      totalKills: totalKills ?? this.totalKills,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'maxHealth': maxHealth,
      'currentHealth': currentHealth,
      'speed': speed,
      'abilities': abilities.map((a) => a.name).toList(),
      'currentlyDelving': currentlyDelving,
      'level': level,
      'currentXP': currentXP,
      'totalKills': totalKills,
    };
  }

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'],
      maxHealth: json['maxHealth'],
      speed: json['speed'],
      currentHealth: json['currentHealth'],
      abilities:
          (json['abilities'] as List)
              .map((name) => getAbilityByName(name))
              .toList(),
      currentlyDelving: json['currentlyDelving'],
      level: json['level'],
      currentXP: json['level'],
      totalKills: json['totalKills'],
    );
  }

  void gainXP(int xpEarned) {
    currentXP += xpEarned;

    while (currentXP >= nextLevelXP) {
      // Calculate remaining XP after level up
      currentXP -= nextLevelXP;
      _levelUp();
    }
  }

  void _levelUp() {
    level++;

    // stat increases
    maxHealth = (maxHealth * _healthMultiplier).ceil();
    currentHealth = maxHealth;
  }
}

List<Character> getThreeRandomCharacters() {
  final random = Random();
  if (allCharacters.length < 3) {
    throw Exception('Not enough characters to select three random ones.');
  }
  allCharacters.shuffle(random);
  return allCharacters.take(3).toList();
}
