import 'package:delve/Ability/ability.dart';
import 'package:delve/Ability/ability_list.dart';

class Character {
  final String name;
  int maxHealth;
  int currentHealth;
  int speed;
  List<Ability> abilities;

  Character({
    required this.name,
    required this.maxHealth,
    required this.speed,
    required this.abilities,
    int? currentHealth,
  }) : currentHealth = currentHealth ?? maxHealth;

  Character.copy(Character other)
    : name = other.name,
      maxHealth = other.maxHealth,
      currentHealth = other.currentHealth,
      speed = other.speed,
      abilities = List.from(other.abilities);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'maxHealth': maxHealth,
      'currentHealth': currentHealth,
      'speed': speed,
      'abilities': abilities.map((a) => a.name).toList(),
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
    );
  }

  bool get isAlive => currentHealth > 0;
}
