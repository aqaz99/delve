import 'package:delve/Ability/ability_list.dart';
import 'package:delve/Battle/battle_service.dart';
import 'package:delve/character.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(DungeonApp());

class DungeonApp extends StatelessWidget {
  const DungeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Delve - Auto Battler')),
        body: DungeonGame(),
      ),
    );
  }
}

class DungeonGame extends StatefulWidget {
  const DungeonGame({super.key});

  @override
  _DungeonGameState createState() => _DungeonGameState();
}

class _DungeonGameState extends State<DungeonGame> {
  late GameController _game;
  final List<String> _log = [];
  final _logController = ScrollController();

  @override
  void initState() {
    super.initState();
    _game = GameController(
      onLog: (msg) => setState(() => _log.add(msg)),
      onGameOver: () => setState(() {}),
    );
    _startGameLoop();
  }

  void _startGameLoop() async {
    while (_game.isRunning) {
      await _game.progress();
      _scrollToBottom();

      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logController.jumpTo(_logController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Controls
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                child: Text("Pause"),
                onPressed: () => setState(() => {_scrollToBottom()}),
              ),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: _resetGame, child: const Text('Reset')),
            ],
          ),
        ),

        // Game Info
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                'Depth: ${_game.depth}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTeamPanel('Party', _game.party),
                  _buildTeamPanel('Enemies', _game.enemies),
                ],
              ),
            ],
          ),
        ),

        // Battle Log
        Expanded(
          child: ListView.builder(
            controller: _logController,
            itemCount: _log.length,
            itemBuilder:
                (context, i) => ListTile(
                  title: Text(_log[i], style: const TextStyle(fontSize: 14)),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamPanel(String title, List<Character> members) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ...members.map(
          (c) => Text(
            '${c.name}: ${c.currentHealth} HP',
            style: TextStyle(color: c.isAlive ? Colors.black : Colors.red),
          ),
        ),
      ],
    );
  }

  void _resetGame() {
    setState(() {
      _game = GameController(
        onLog: (msg) => setState(() => _log.add(msg)),
        onGameOver: () => setState(() {}),
      );
      _log.clear();
    });
    _startGameLoop();
  }
}

class GameController {
  final List<Character> party;
  List<Character> enemies = [];
  int depth = 1;
  bool isRunning = true;
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

    await _battle.run();

    if (!ctx.partyAlive) {
      onLog('GAME OVER');
      isRunning = false;
      onGameOver();
      return;
    }

    depth++;
    // Add levels / checkpoints / fireside recovery
  }
}

class DungeonService {
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
}
