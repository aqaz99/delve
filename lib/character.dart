import 'package:delve/Ability/ability.dart';

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
  }) : currentHealth = maxHealth;

  Character.copy(Character other)
    : name = other.name,
      maxHealth = other.maxHealth,
      currentHealth = other.currentHealth,
      speed = other.speed,
      abilities = List.from(other.abilities);

  bool get isAlive => currentHealth > 0;
}
