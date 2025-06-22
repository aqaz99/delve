import 'dart:math';

import 'package:delve/Battle/battle_service.dart';
import 'package:delve/Character/character.dart';
import 'package:delve/Character/enemyTemplate.dart';
import 'package:delve/Party/party_service.dart';
import 'package:delve/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DungeonService {
  final PartyService partyService;
  final Function(BattleState) onStateUpdate;
  final Function() onGameOver;
  bool showEvent = false;

  List<Character> enemies = [];
  int currentRound = 0;
  int depth = 1;
  bool roundStarted = false;
  bool gameStarted = false;
  bool defeatedDepth = false;

  late BattleService _battle;

  DungeonService({
    required this.partyService,
    required this.onStateUpdate,
    required this.onGameOver,
  });

  Future<void> loadProgress(WidgetRef ref) async {
    final savedState = await partyService.loadDelveState();
    if (savedState != null) {
      depth = savedState.depth;
      currentRound = savedState.currentRound;
      defeatedDepth = savedState.defeatedDepth;
      enemies = savedState.enemies;

      ref.read(enemyProvider.notifier).state = List<Character>.from(enemies);

      final loadedParty = await partyService.loadParty();
      ref.read(partyProvider.notifier).setParty(loadedParty);
    }
  }

  Future<void> saveProgress(WidgetRef ref) async {
    final currentParty = ref.read(partyProvider);
    await partyService.saveDelveState(
      DelveState(
        depth: depth,
        currentRound: currentRound,
        defeatedDepth: defeatedDepth,
        enemies: enemies,
      ),
    );
    await partyService.saveParty(currentParty);
  }

  Future<List<Character>> loadDungeonParty(WidgetRef ref) async {
    final party = await partyService.loadParty();
    ref.read(partyProvider.notifier).setParty(party);
    return party;
  }

  List<Character> generateEnemies(int depth) {
    final random = Random();
    final enemyCount = 3;
    final List<Character> enemies = [];

    for (int i = 0; i < enemyCount; i++) {
      final template = enemyTemplates[random.nextInt(enemyTemplates.length)];
      final int level = depth; // Level equals dungeon depth

      // Scale stats and exp
      final int maxHealth = (template.baseHealth * pow(1.2, level - 1)).round();
      final int speed = (template.baseSpeed * pow(1.1, level - 1)).round();
      final int expValue = (template.baseExp * pow(1.15, level - 1)).round();

      enemies.add(
        Character(
          name: '${template.name} ${i + 1}',
          maxHealth: maxHealth,
          currentHealth: maxHealth,
          speed: speed,
          abilities: List.from(template.abilities),
          currentlyDelving: true,
          level: level,
          currentXP: 0,
          totalKills: 0,
          abilityPoints: 0,
          // Add these fields to your Character class if not present:
          // int level, int expValue
        )..expValue = expValue,
      );
    }
    return enemies;
  }

  Future<void> goDeeper(WidgetRef ref) async {
    depth++;

    // Every 3 depth levels, have an event for the player
    if (depth % 3 == 0) {
      showEvent = true;
    } else {
      showEvent = false;
    }

    currentRound = 0;
    generateEncounter(ref);
    await saveProgress(ref);
  }

  void handleEventChoice(WidgetRef ref, String choice) {
    final partyNotifier = ref.read(partyProvider.notifier);
    switch (choice) {
      case 'rest':
        partyNotifier.healParty(10);
        break;
      case 'loot':
        break;
      case 'continue':
        break;
    }
    showEvent = false;
  }

  Future<void> clearDungeonRun(WidgetRef ref) async {
    depth = 1;
    currentRound = 0;
    enemies = generateEnemies(depth);
    await saveProgress(ref);
  }

  void setAllyCharactersActivelyDelving(WidgetRef ref) {
    final party = ref.read(partyProvider);
    final updatedParty =
        party.map((c) => c.copyWith(currentlyDelving: true)).toList();
    ref.read(partyProvider.notifier).setParty(updatedParty);
  }

  void generateEncounter(WidgetRef ref) {
    gameStarted = true;
    enemies = showEvent ? [] : generateEnemies(depth);
    setAllyCharactersActivelyDelving(ref);
  }

  Future<void> progressRound(WidgetRef ref) async {
    roundStarted = true;
    final currentParty = ref.read(partyProvider);

    while (enemies.any((c) => c.isAlive)) {
      currentRound++;

      var ctx = BattleContext(List.from(currentParty), enemies);
      _battle = BattleService(
        context: ctx,
        onState: (state) => onStateUpdate(state),
      );

      await _battle.runBattleRound(currentRound);

      ref.read(partyProvider.notifier).setParty(ctx.currentParty);
      ref.read(enemyProvider.notifier).state = ctx.currentEnemies;
      enemies = ctx.currentEnemies;

      await saveProgress(ref);
      roundStarted = false;

      if (!ctx.partyAlive) {
        onGameOver();
        return;
      }
    }
  }
}

class DelveState {
  final int depth;
  final int currentRound;
  final bool defeatedDepth;
  final List<Character> enemies;

  DelveState({
    required this.depth,
    required this.currentRound,
    required this.defeatedDepth,
    required this.enemies,
  });

  factory DelveState.fromJson(Map<String, dynamic> json) {
    return DelveState(
      depth: json['depth'],
      currentRound: json['currentRound'],
      defeatedDepth: json['defeatedDepth'],
      enemies:
          (json['enemies'] as List).map((e) => Character.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'depth': depth,
    'currentRound': currentRound,
    'defeatedDepth': defeatedDepth,
    'enemies': enemies.map((e) => e.toJson()).toList(),
  };
}
