// character_list.dart
import 'package:delve/Ability/ability_list.dart';
import 'package:delve/Character/character.dart';

final characterWarrior = Character(
  name: 'Warrior',
  maxHealth: 30,
  speed: 5,
  abilities: [abilityKnightsSwing],
  currentlyDelving: false,
);
final characterMage = Character(
  name: 'Mage',
  maxHealth: 25,
  speed: 4,
  abilities: [abilityFireball],
  currentlyDelving: false,
);

final characterCleric = Character(
  name: 'Cleric',
  maxHealth: 25,
  speed: 3,
  abilities: [abilityLesserHeal],
  currentlyDelving: false,
);

final characterRogue = Character(
  name: 'Rogue',
  maxHealth: 20,
  speed: 6,
  abilities: [abilityBackstab],
  currentlyDelving: false,
);

final characterWarlock = Character(
  name: 'Warlock',
  maxHealth: 22,
  speed: 4,
  abilities: [abilityReap],
  currentlyDelving: false,
);

final List<Character> allCharacters = [
  characterWarrior,
  characterMage,
  characterCleric,
  characterRogue,
  characterWarlock,
];
