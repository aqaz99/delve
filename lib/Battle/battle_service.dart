import 'dart:async';
import 'dart:math';

import 'package:delve/Ability/ability.dart';
import 'package:delve/Ability/ability_list.dart';
import 'package:delve/character.dart';
import 'package:delve/enums.dart';

class BattleService {
  final BattleContext _context;
  final Function(String) onLog;
  final _random = Random();
  var _isBattleActive = false;

  BattleService({required this.onLog, required BattleContext context})
    : _context = context;

  Future<void> run() async {
    _isBattleActive = true;

    final participants = _getInitiativeOrder();

    while (_isBattleActive && _context.battleActive) {
      for (final character in participants) {
        if (!_isBattleActive) break;
        await _processTurn(character);
        if (!_context.battleActive) break;
      }
    }

    if (_isBattleActive) {
      onLog(_context.partyAlive ? 'Victory!' : 'Defeat!');
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
      await Future.delayed(const Duration(milliseconds: 500));
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

    if (targets.isEmpty) {
      onLog(
        '${caster.name} tried to use ${ability.name} but found no targets!',
      );
      return;
    }

    ability.effect.apply(caster, targets, ability.scale);
    onLog(
      '${caster.name} uses ${ability.name} on ${targets.map((t) => t.name).join(', ')}',
    );

    _context.removeDeadCharacters();
  }

  void toggleBattle() {
    _isBattleActive = !_isBattleActive;
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
