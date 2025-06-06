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

  Character({
    required this.name,
    required this.maxHealth,
    required this.speed,
    required this.abilities,
    required this.currentlyDelving,
    int? currentHealth,
  }) : currentHealth = currentHealth ?? maxHealth;

  Character.copy(Character other)
    : name = other.name,
      maxHealth = other.maxHealth,
      currentHealth = other.currentHealth,
      speed = other.speed,
      currentlyDelving = other.currentlyDelving,
      abilities = List.from(other.abilities);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'maxHealth': maxHealth,
      'currentHealth': currentHealth,
      'speed': speed,
      'abilities': abilities.map((a) => a.name).toList(),
      'currentlyDelving': currentlyDelving,
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
    );
  }

  bool get isAlive => currentHealth > 0;
}

List<Character> getThreeRandomCharacters() {
  final random = Random();
  if (allCharacters.length < 3) {
    throw Exception('Not enough characters to select three random ones.');
  }
  allCharacters.shuffle(random);
  return allCharacters.take(3).toList();
}
