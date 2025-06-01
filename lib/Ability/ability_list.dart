// Maybe JSON in the future?

import 'package:delve/Ability/ability.dart';
import 'package:delve/Ability/effects.dart';
import 'package:delve/Ability/target_resolvers.dart';
import 'package:delve/enums.dart';

final abilityStrike = Ability(
  name: 'Strike',
  type: AbilityType.damage,
  scale: 4,
  targetResolver: RandomEnemyResolver(1),
  effect: DamageEffect(),
);

final abilityFireball = Ability(
  name: 'Fireball',
  type: AbilityType.damage,
  scale: 5,
  targetResolver: RandomEnemyResolver(2),
  effect: DamageEffect(),
);

final abilityKnightsSwing = Ability(
  name: 'Knight\'s Swing',
  type: AbilityType.damage,
  scale: 8,
  targetResolver: FrontEnemyResolver(),
  effect: DamageEffect(),
);

final abilityLesserHeal = Ability(
  name: 'Lesser Heal',
  type: AbilityType.heal,
  scale: 6, // Max value
  targetResolver: LowestHealthAllyResolver(1), // New resolver
  effect: HealEffect(),
);
