// battleService.dart
import 'dart:async';
import 'dart:math';

import 'package:delve/Ability/ability.dart';
import 'package:delve/Ability/ability_list.dart';
import 'package:delve/character.dart';
import 'package:delve/enums.dart';

class BattleService {
  final BattleContext _context;
  final Function(BattleState) onState;
  final _random = Random();

  BattleService({required this.onState, required BattleContext context})
    : _context = context;

  Future<void> runBattleRound() async {
    final participants = _getInitiativeOrder();

    for (final character in participants) {
      await _processTurn(character);
    }
  }

  List<Character> _getInitiativeOrder() {
    final allParticipants = [..._context.allies, ..._context.enemies]
      ..shuffle(_random);
    return allParticipants.where((c) => c.isAlive).toList();
  }

  Future<void> _processTurn(Character character) async {
    if (!character.isAlive) return;

    final ability = _selectAbility(character);

    if (ability != null) {
      useAbility(character, ability);
    }
  }

  Ability? _selectAbility(Character caster) {
    // If there is an injured ally and we have a heal, use it
    if (caster.abilities.any((ability) => ability.type == AbilityType.heal)) {
      for (var ally in _context.allies) {
        if (ally.isAlive && ally.currentHealth < ally.maxHealth / 2) {
          print(
            "Found healing target ${ally.name}: ${ally.currentHealth}/${ally.maxHealth}",
          );
          return caster.abilities.firstWhere(
            (ability) => ability.type == AbilityType.heal,
          );
        }
      }
    }

    // Roll on each ability, if we get it use it
    for (var ability in caster.abilities) {
      // If the ability isn't a guarenteed heal we roll
      if (ability.type != AbilityType.heal && ability.chance != 100) {
        final roll = _random.nextInt(100) + 1;
        if (roll <= ability.chance) {
          return ability;
        }
      }
    }
    // Otherwise use strike
    return abilityStrike;
  }

  void useAbility(Character caster, Ability ability) {
    if (!caster.isAlive) return;

    // Determine actual allies/enemies based on caster team
    final isAlly = _context.allies.contains(caster);
    final casterAllies = isAlly ? _context.allies : _context.enemies;
    final casterEnemies = isAlly ? _context.enemies : _context.allies;

    final targets =
        ability.targetResolver
            .resolve(
              caster: caster,
              allies: casterAllies,
              enemies: casterEnemies,
            )
            .where((t) => t.isAlive)
            .toList();

    // if (targets.isEmpty) {
    //   onLog(
    //     '${caster.name} tried to use ${ability.name} but found no targets!',
    //   );
    //   return;
    // }

    ability.effect.apply(caster, targets, ability.scale);
    _context.removeDeadCharacters();
    final state = BattleState(
      logMessage:
          '${caster.name} used ${ability.name} on ${targets.map((t) => t.name).join(', ')} for ${ability.scale}.',
      partySnapshot: _deepCopy(_context.allies),
      enemiesSnapshot: _deepCopy(_context.enemies),
    );
    onState(state);
  }

  static List<Character> _deepCopy(List<Character> originals) {
    return originals.map((c) => Character.copy(c)).toList();
  }
}

class BattleContext {
  final List<Character> allies;
  final List<Character> enemies;

  BattleContext(this.allies, this.enemies);

  bool get battleActive => partyAlive && enemiesAlive;
  bool get partyAlive => allies.any((c) => c.isAlive);
  bool get enemiesAlive => enemies.any((c) => c.isAlive);

  void removeDeadCharacters() {
    allies.removeWhere((c) => !c.isAlive);
    enemies.removeWhere((c) => !c.isAlive);
  }
}

class BattleState {
  final String logMessage;
  final List<Character> partySnapshot;
  final List<Character> enemiesSnapshot;

  BattleState({
    required this.logMessage,
    required this.partySnapshot,
    required this.enemiesSnapshot,
  });
}
