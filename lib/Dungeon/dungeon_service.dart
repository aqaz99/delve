import 'package:delve/Battle/battle_service.dart';
import 'package:delve/Character/character.dart';
import 'package:delve/Party/party_service.dart';
import 'package:delve/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DungeonService {
  final PartyService partyService;
  final Function(BattleState) onStateUpdate;
  final Function() onGameOver;

  List<Character> enemies = [];
  int currentRound = 0;
  int depth = 1;
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
    return List.generate(
      3,
      (i) => Character(
        name: 'Goblin ${i + 1}',
        maxHealth: 15 + depth * 3,
        speed: 3 + depth,
        abilities: [],
        currentlyDelving: true,
      ),
    );
  }

  Future<void> goDeeper(WidgetRef ref) async {
    depth++;
    currentRound = 0;
    generateEncounter(ref);
    await saveProgress(ref);
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
    enemies = generateEnemies(depth);
    setAllyCharactersActivelyDelving(ref);
  }

  Future<void> progressRound(WidgetRef ref) async {
    final currentParty = ref.read(partyProvider);

    while (enemies.any((c) => c.isAlive)) {
      currentRound++;

      var ctx = BattleContext(List.from(currentParty), enemies);
      _battle = BattleService(
        context: ctx,
        onState: (state) => onStateUpdate(state),
      );

      await _battle.runBattleRound(currentRound);

      // Update with current battle state
      ref.read(partyProvider.notifier).setParty(ctx.currentParty);
      ref.read(enemyProvider.notifier).state = ctx.currentEnemies;
      enemies = ctx.currentEnemies; // Keep local state in sync

      await saveProgress(ref);

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
