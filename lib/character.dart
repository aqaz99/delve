import 'package:delve/Ability/ability.dart';

class Character {
  final String name;
  int hp;
  int position;
  int speed;
  List<Ability> abilities;

  Character({
    required this.name,
    required this.hp,
    required this.position,
    required this.speed,
    required this.abilities,
  });

  bool get isAlive => hp > 0;
}
