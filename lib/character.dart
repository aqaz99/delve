import 'package:delve/Ability/ability.dart';
import 'package:delve/Ability/ability_list.dart';

class Character {
  final String name;
  int hp;
  int speed;
  List<Ability> abilities;

  Character({
    required this.name,
    required this.hp,
    required this.speed,
    required this.abilities,
  }) {
    abilities.add(abilityStrike);
  }

  bool get isAlive => hp > 0;
}
