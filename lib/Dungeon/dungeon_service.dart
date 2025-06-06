// dungeon_service.dart
import 'package:delve/Battle/battle_service.dart';
import 'package:delve/Character/character.dart';
import 'package:delve/Party/party_service.dart';

// Add levels / checkpoints / fireside recovery
class DungeonService {
  List<Character> party = [];
  List<Character> enemies = [];
  int currentRound = 0;
  int depth = 1;
  final Function(BattleState) onStateUpdate;
  bool gameStarted = false;
  bool defeatedDepth = false;
  final Function() onGameOver;
  final PartyService partyService = PartyService();

  late BattleService _battle;

  DungeonService({required this.onStateUpdate, required this.onGameOver});

  Future<void> loadProgress() async {
    final savedState = await partyService.loadDelveState();
    if (savedState != null) {
      depth = savedState.depth;
      currentRound = savedState.currentRound;
      defeatedDepth = savedState.defeatedDepth;
      enemies = savedState.enemies;
      for (var element in savedState.enemies) {
        print("${element.name} - ${element.currentHealth}");
      }
    }
  }

  Future<void> saveProgress() async {
    await partyService.saveDelveState(
      DelveState(
        depth: depth,
        currentRound: currentRound,
        defeatedDepth: defeatedDepth,
        enemies: enemies,
      ),
    );
    await partyService.saveParty(party);
  }

  Future<List<Character>> loadDungeonParty() async {
    party = await partyService.loadParty();
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

  void goDeeper() {
    depth++;
    currentRound = 0;
    generateEncounter();
    saveProgress();
  }

  void setAllyCharactersActivelyDelving() {
    for (var character in party) {
      character.currentlyDelving = true;
    }
  }

  void generateEncounter() {
    gameStarted = true;
    enemies = generateEnemies(depth);
    setAllyCharactersActivelyDelving();
  }

  Future<void> progressRound() async {
    while (enemies.any((c) => c.isAlive)) {
      currentRound++;

      var ctx = BattleContext(List.from(party), enemies);
      _battle = BattleService(
        context: ctx,
        onState: (state) => onStateUpdate(state),
      );

      await _battle.runBattleRound(currentRound);
      await saveProgress();
      partyService.saveParty(party);
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
