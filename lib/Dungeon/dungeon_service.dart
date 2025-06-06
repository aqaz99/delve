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
  final PartyService _partyService = PartyService();

  late BattleService _battle;

  DungeonService({required this.onStateUpdate, required this.onGameOver});

  Future<List<Character>> loadDungeonParty() async {
    party = await _partyService.loadParty();
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

      if (!ctx.partyAlive) {
        onGameOver();
        return;
      }
    }
  }
}
