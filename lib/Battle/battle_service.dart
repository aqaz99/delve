import 'dart:async';
import 'dart:math';

import 'package:delve/Ability/ability.dart';
import 'package:delve/character.dart';

class BattleService {
  final BattleContext _context;
  final Function(String) onLog;
  final _random = Random();
  var _isBattleActive = false;
  var _isBattlePaused = false;

  BattleService({required this.onLog, required BattleContext context})
    : _context = context;

  Future<void> run() async {
    _isBattleActive = true;

    while (_isBattleActive && _context.battleActive && !_isBattlePaused) {
      final participants = _getInitiativeOrder();

      for (final character in participants) {
        if (!_isBattleActive) break;
        await _processTurn(character);
        if (!_context.battleActive) break;
      }
    }

    onLog(_context.partyAlive ? 'Victory!' : 'Defeat!');
  }

  List<Character> _getInitiativeOrder() {
    final allParticipants = [..._context.allies, ..._context.enemies]
      ..shuffle(_random);
    return allParticipants.where((c) => c.isAlive).toList();
  }

  Future<void> _processTurn(Character character) async {
    if (!character.isAlive) return;

    final isAlly = _context.allies.contains(character);
    final ability = _selectAbility(character, isAlly);

    if (ability != null) {
      useAbility(character, ability);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Ability? _selectAbility(Character caster, bool isAlly) {
    final availableAbilities =
        caster.abilities
            .where((a) => a.canUseFromPosition(caster.position))
            .toList();

    if (availableAbilities.isEmpty) return null;

    return isAlly
        ? availableAbilities.first
        : availableAbilities[_random.nextInt(availableAbilities.length)];
  }

  void useAbility(Character caster, Ability ability) {
    if (!caster.isAlive || !ability.canUseFromPosition(caster.position)) return;

    final targets = ability.targetResolver.resolve(
      caster: caster,
      allies: _context.allies,
      enemies: _context.enemies,
    );

    for (var element in targets) {
      print("target: ${element.name}");
    }

    // Ensure targets are filtered based on allegiance
    final validTargets =
        _context.allies.contains(caster)
            ? targets
                .where((t) => _context.enemies.contains(t) && t.isAlive)
                .toList()
            : targets
                .where((t) => _context.allies.contains(t) && t.isAlive)
                .toList();

    print(_context.allies);
    print(_context.enemies);

    if (validTargets.isEmpty) {
      onLog(
        '${caster.name} tried to use ${ability.name} but found no valid targets!',
      );
      return;
    }

    ability.effect.apply(caster, validTargets, ability.scale);
    onLog(
      '${caster.name} uses ${ability.name} on ${validTargets.map((t) => t.name).join(', ')}',
    );

    _context.removeDeadCharacters();
  }

  void stopBattle() {
    _isBattleActive = false;
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
