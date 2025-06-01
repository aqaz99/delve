// Maybe JSON in the future?

import 'package:delve/Ability/ability.dart';
import 'package:delve/Ability/effects.dart';
import 'package:delve/Ability/target_resolvers.dart';
import 'package:delve/enums.dart';

final abilityStrike = Ability(
  name: 'Strike',
  type: AbilityType.damage,
  validPositions: [0, 1, 2], // Usable from any position
  scale: 4,
  targetResolver: FrontEnemyResolver(),
  effect: DamageEffect(),
);

final abilityFireball = Ability(
  name: 'Fireball',
  type: AbilityType.damage,
  validPositions: [2], // Back position only
  scale: 5,
  targetResolver: RandomEnemyResolver(2),
  effect: DamageEffect(),
);

final abilityKnightsSwing = Ability(
  name: 'Knight\'s Swing',
  type: AbilityType.damage,
  validPositions: [0, 1], // Front and middle positions
  scale: 8,
  targetResolver: FrontEnemyResolver(),
  effect: DamageEffect(),
);

final abilityLesserHeal = Ability(
  name: 'Lesser Heal',
  type: AbilityType.heal,
  validPositions: [0, 1, 2], // Front and middle positions
  scale: 6, // Max value
  targetResolver: LowestHealthAllyResolver(1), // New resolver
  effect: DamageEffect(),
);
