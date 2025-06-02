import 'package:delve/Ability/ability_list.dart';
import 'package:delve/Battle/battle_service.dart';
import 'package:delve/Dungeon/dungeonService.dart';
import 'package:delve/character.dart';

class GameController {
  final List<Character> party;
  List<Character> enemies = [];
  int depth = 1;
  final Function(String) onLog;
  final Function() onGameOver;

  late BattleService _battle;

  GameController({required this.onLog, required this.onGameOver})
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

  Future<void> progress() async {
    enemies = DungeonService().generateEnemies(depth);
    onLog('\n=== Depth $depth ===');

    var ctx = BattleContext(List.from(party), enemies);
    _battle = BattleService(context: ctx, onLog: onLog);

    await _battle.runBattle();

    if (!ctx.partyAlive) {
      onLog('GAME OVER');
      onGameOver();
      return;
    }

    depth++;
    // Add levels / checkpoints / fireside recovery
  }
}
