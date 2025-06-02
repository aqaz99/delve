// character_list.dart
import 'package:delve/Ability/ability_list.dart';
import 'package:delve/Character/character.dart';

final characterWarrior = Character(
  name: 'Warrior',
  maxHealth: 30,
  speed: 5,
  abilities: [abilityKnightsSwing],
);
final characterMage = Character(
  name: 'Mage',
  maxHealth: 25,
  speed: 4,
  abilities: [abilityFireball],
);

final characterCleric = Character(
  name: 'Cleric',
  maxHealth: 25,
  speed: 3,
  abilities: [abilityLesserHeal],
);

final characterRogue = Character(
  name: 'Rogue',
  maxHealth: 20,
  speed: 6,
  abilities: [abilityBackstab],
);

final characterWarlock = Character(
  name: 'Warlock',
  maxHealth: 22,
  speed: 4,
  abilities: [abilityReap],
);

final List<Character> allCharacters = [
  characterWarrior,
  characterMage,
  characterCleric,
  characterRogue,
  characterWarlock,
];
