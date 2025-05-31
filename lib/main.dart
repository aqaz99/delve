import 'dart:math';

var noEnemy = Character('no_enemy', 0, 0);
void main() {
  final party = [
    Character('Warrior', 20, 5),
    Character('Mage', 12, 7),
    Character('Healer', 15, 3),
  ];

  final dungeon = DungeonService();
  int depth = 1;

  while (true) {
    print('\n--- Dungeon Depth $depth ---');
    final enemies = dungeon.generateEnemies(depth);

    final battle = BattleService(List<Character>.from(party), enemies);
    battle.run();

    if (!battle.partyAlive()) {
      print('Your party has been defeated. Game over.');
      break;
    }

    print('Cleared depth $depth!');
    depth++;

    if (depth > 3) {
      print('You have conquered the dungeon! Congratulations!');
      break;
    }
  }
}

// --- Simple Character Model ---
class Character {
  final String name;
  int hp;
  final int attack;

  Character(this.name, this.hp, this.attack);

  bool get isAlive => hp > 0;
}

// --- Simple Dungeon Service ---
class DungeonService {
  List<Character> generateEnemies(int depth) {
    final rand = Random();
    return List.generate(
      3,
      (i) => Character(
        'Goblin ${i + 1}',
        10 + depth * 2 + rand.nextInt(3),
        2 + depth,
      ),
    );
  }
}

// --- Simple Battle Service ---
class BattleService {
  final List<Character> party;
  final List<Character> enemies;

  BattleService(this.party, this.enemies);

  void run() {
    while (partyAlive() && enemiesAlive()) {
      // Each alive party member attacks first alive enemy
      for (final c in party.where((c) => c.isAlive)) {
        final target = enemies.firstWhere(
          (e) => e.isAlive,
          orElse: () => noEnemy,
        );
        if (target == noEnemy) break;
        target.hp -= c.attack;
        print(
          '${c.name} attacks ${target.name} for ${c.attack} damage (Enemy HP: ${target.hp})',
        );
        if (target.hp <= 0) {
          print('${target.name} is defeated!');
        }
      }

      // Each alive enemy attacks first alive party member
      for (final e in enemies.where((e) => e.isAlive)) {
        final target = party.firstWhere(
          (c) => c.isAlive,
          orElse: () => noEnemy,
        );
        if (target == noEnemy) break;
        target.hp -= e.attack;
        print(
          '${e.name} attacks ${target.name} for ${e.attack} damage (Party HP: ${target.hp})',
        );
        if (target.hp <= 0) {
          print('${target.name} is defeated!');
        }
      }
    }
  }

  bool partyAlive() => party.any((c) => c.isAlive);
  bool enemiesAlive() => enemies.any((e) => e.isAlive);
}
