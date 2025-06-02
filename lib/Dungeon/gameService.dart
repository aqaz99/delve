// gameController.dart
import 'package:delve/Ability/ability_list.dart';
import 'package:delve/Battle/battleService.dart';
import 'package:delve/Dungeon/dungeonService.dart';
import 'package:delve/character.dart';

class GameController {
  List<Character> party;
  List<Character> enemies = [];
  int depth = 1;
  final Function(BattleState) onStateUpdate;
  bool gameStarted = false;
  final Function() onGameOver;

  late BattleService _battle;

  GameController({required this.onStateUpdate, required this.onGameOver})
    : party = _defaultParty();

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

  void goDeeper() {
    depth++;
    generateEncounter();
  }

  void generateEncounter() {
    gameStarted = true;
    enemies = DungeonService().generateEnemies(depth);
  }

  Future<void> progressRound() async {
    var ctx = BattleContext(List.from(party), enemies);
    _battle = BattleService(
      context: ctx,
      onState: (state) => onStateUpdate(state), // New callback
    );

    await _battle.runBattleRound();

    if (!ctx.partyAlive) {
      // onLog('GAME OVER');
      onGameOver();
      return;
    }

    // depth++;
    // Add levels / checkpoints / fireside recovery
  }
}
