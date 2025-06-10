// effects.dart
import 'dart:math';
import 'package:delve/Character/character.dart';

abstract class AbilityEffect {
  void apply(Character caster, List<Character> targets, int scale);
}

class DamageEffect implements AbilityEffect {
  @override
  void apply(Character caster, List<Character> targets, int scale) {
    for (final target in targets) {
      if ((target.currentHealth - scale) <= 0) {
        target.currentHealth = 0;
        caster.totalKills += 1;
      } else {
        target.currentHealth -= scale;
      }
    }
  }
}

class HealEffect implements AbilityEffect {
  @override
  void apply(Character caster, List<Character> targets, int scale) {
    for (final target in targets) {
      if ((target.currentHealth + scale) >= target.maxHealth) {
        target.currentHealth = target.maxHealth;
      } else {
        target.currentHealth += scale;
      }
    }
  }
}

class RandomHealEffect implements AbilityEffect {
  final Random _random = Random();

  @override
  void apply(Character caster, List<Character> targets, int scale) {
    for (final target in targets) {
      final healAmount = _random.nextInt(scale) + scale ~/ 2;
      if ((target.currentHealth + scale) <= target.maxHealth) {
        target.currentHealth = target.maxHealth;
      } else {
        target.currentHealth += healAmount;
      }
      print('${caster.name} heals ${target.name} for $healAmount HP');
    }
  }
}
