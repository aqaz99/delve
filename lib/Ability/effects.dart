import 'dart:math';

import 'package:delve/character.dart';

abstract class AbilityEffect {
  void apply(Character caster, List<Character> targets, int scale);
}

class DamageEffect implements AbilityEffect {
  @override
  void apply(Character caster, List<Character> targets, int scale) {
    for (final target in targets) {
      target.hp -= scale;
    }
  }
}

class HealEffect implements AbilityEffect {
  @override
  void apply(Character caster, List<Character> targets, int scale) {
    for (final target in targets) {
      target.hp += scale;
    }
  }
}

class RandomHealEffect implements AbilityEffect {
  final Random _random = Random();

  @override
  void apply(Character caster, List<Character> targets, int scale) {
    for (final target in targets) {
      final healAmount = _random.nextInt(scale) + scale ~/ 2;
      target.hp += healAmount;
      print('${caster.name} heals ${target.name} for $healAmount HP');
    }
  }
}
