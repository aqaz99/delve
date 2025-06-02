import 'package:delve/Dungeon/gameController.dart';
import 'package:delve/character.dart';
import 'package:flutter/material.dart';

class DelveScreen extends StatefulWidget {
  @override
  _DelveScreenState createState() => _DelveScreenState();
}

class _DelveScreenState extends State<DelveScreen> {
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
  }

  void _startGameLoop() async {
    await _game.progress();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_logController.hasClients) {
      _logController.jumpTo(_logController.position.maxScrollExtent);
    }
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
                child: Text("Simulate"),
                onPressed:
                    () => setState(() {
                      _startGameLoop();
                    }),
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
}

class Game {
  int depth = 0;
  List<String> party = ['Hero', 'Mage', 'Warrior'];
  List<String> enemies = ['Goblin', 'Orc', 'Troll'];

  Game();
}
