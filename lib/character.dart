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

  bool get isAlive => currentHealth > 0;
}
