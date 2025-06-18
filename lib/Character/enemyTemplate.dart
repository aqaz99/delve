import 'package:delve/Ability/ability.dart';

class EnemyTemplate {
  final String name;
  final int baseHealth;
  final int baseSpeed;
  final int baseExp;
  final List<Ability> abilities;

  const EnemyTemplate({
    required this.name,
    required this.baseHealth,
    required this.baseSpeed,
    required this.baseExp,
    required this.abilities,
  });
}

const enemyTemplates = [
  EnemyTemplate(
    name: 'Goblin',
    baseHealth: 15,
    baseSpeed: 3,
    baseExp: 50,
    abilities: [],
  ),
  EnemyTemplate(
    name: 'Orc',
    baseHealth: 20,
    baseSpeed: 2,
    baseExp: 75,
    abilities: [],
  ),
  EnemyTemplate(
    name: 'Spider',
    baseHealth: 10,
    baseSpeed: 5,
    baseExp: 40,
    abilities: [],
  ),
];
