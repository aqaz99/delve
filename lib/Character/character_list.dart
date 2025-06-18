// character_list.dart
import 'package:delve/Ability/ability_list.dart';
import 'package:delve/Character/character.dart';

final characterWarrior = Character(
  name: 'Warrior',
  maxHealth: 40,
  speed: 5,
  abilities: [abilityKnightsSwing],
  currentlyDelving: false,
  level: 1,
  currentXP: 0,
  totalKills: 0,
);
final characterMage = Character(
  name: 'Mage',
  maxHealth: 30,
  speed: 4,
  abilities: [abilityFireball],
  currentlyDelving: false,
  level: 1,
  currentXP: 0,
  totalKills: 0,
);

final characterCleric = Character(
  name: 'Cleric',
  maxHealth: 35,
  speed: 3,
  abilities: [abilityLesserHeal],
  currentlyDelving: false,
  level: 1,
  currentXP: 0,
  totalKills: 0,
);

final characterRogue = Character(
  name: 'Rogue',
  maxHealth: 25,
  speed: 6,
  abilities: [abilityBackstab],
  currentlyDelving: false,
  level: 1,
  currentXP: 0,
  totalKills: 0,
);

final characterWarlock = Character(
  name: 'Warlock',
  maxHealth: 28,
  speed: 4,
  abilities: [abilityReap],
  currentlyDelving: false,
  level: 1,
  currentXP: 0,
  totalKills: 0,
);

final List<Character> allCharacters = [
  characterWarrior,
  characterMage,
  characterCleric,
  characterRogue,
  characterWarlock,
];
