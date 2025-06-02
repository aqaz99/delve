// ability_list.dart ? Convert to json?
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
  chance: 100,
);

final abilityFireball = Ability(
  name: 'Fireball',
  type: AbilityType.damage,
  scale: 3,
  targetResolver: RandomEnemyResolver(2),
  effect: DamageEffect(),
  chance: 25,
);

final abilityKnightsSwing = Ability(
  name: 'Knight\'s Swing',
  type: AbilityType.damage,
  scale: 8,
  targetResolver: FrontEnemyResolver(),
  effect: DamageEffect(),
  chance: 50,
);

final abilityLesserHeal = Ability(
  name: 'Lesser Heal',
  type: AbilityType.heal,
  scale: 6, // Max value
  targetResolver: LowestHealthAllyResolver(1),
  effect: HealEffect(),
  chance: 100,
);

final List<Ability> allAbilities = [
  abilityStrike,
  abilityFireball,
  abilityKnightsSwing,
  abilityLesserHeal,
];

Ability getAbilityByName(String name) =>
    allAbilities.firstWhere((a) => a.name == name);
