// dungeon_service.dart
import 'package:delve/Ability/ability_list.dart';
import 'package:delve/Battle/battle_service.dart';
import 'package:delve/Character/character.dart';

// Add levels / checkpoints / fireside recovery
class DungeonService {
  List<Character> party;
  List<Character> enemies = [];
  int currentRound = 0;
  int depth = 1;
  final Function(BattleState) onStateUpdate;
  bool gameStarted = false;
  bool defeatedDepth = false;
  final Function() onGameOver;

  late BattleService _battle;

  DungeonService({required this.onStateUpdate, required this.onGameOver})
    : party = loadInitialParty();

  static List<Character> loadInitialParty() {
    // You'll want to implement async loading here in real app
    return _defaultParty();
  }

  static List<Character> _defaultParty() {
    return [
      Character(
        name: 'Warrior',
        maxHealth: 30,
        speed: 5,
        abilities: [abilityKnightsSwing],
      ),
      Character(
        name: 'Mage',
        maxHealth: 25,
        speed: 4,
        abilities: [abilityFireball],
      ),
      Character(
        name: 'Healer',
        maxHealth: 25,
        speed: 3,
        abilities: [abilityLesserHeal],
      ),
    ];
  }

  List<Character> generateEnemies(int depth) {
    return List.generate(
      3,
      (i) => Character(
        name: 'Goblin ${i + 1}',
        maxHealth: 15 + depth * 3,
        speed: 3 + depth,
        abilities: [],
      ),
    );
  }

  void goDeeper() {
    depth++;
    currentRound = 0;
    generateEncounter();
  }

  void generateEncounter() {
    gameStarted = true;
    enemies = generateEnemies(depth);
  }

  Future<void> progressRound() async {
    currentRound++;

    var ctx = BattleContext(List.from(party), enemies);
    _battle = BattleService(
      context: ctx,
      onState: (state) => onStateUpdate(state),
    );

    await _battle.runBattleRound();

    if (!ctx.partyAlive) {
      onGameOver();
      return;
    }
  }
}
