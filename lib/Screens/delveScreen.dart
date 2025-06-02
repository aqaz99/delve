// delve_screen.dart
import 'package:delve/Battle/battle_service.dart';
import 'package:delve/Dungeon/dungeon_service.dart';
import 'package:delve/Character/character.dart';
import 'package:flutter/material.dart';

class DelveScreen extends StatefulWidget {
  @override
  _DelveScreenState createState() => _DelveScreenState();
}

class _DelveScreenState extends State<DelveScreen> {
  late DungeonService _game;
  final List<BattleState> _stateBuffer = [];
  final List<BattleState> _visibleStates = [];
  bool _isProcessing = false;
  final _logController = ScrollController();

  @override
  void initState() {
    super.initState();
    _game = DungeonService(
      onStateUpdate: _handleNewState,
      onGameOver: () => setState(() {}),
    );
  }

  void _handleNewState(BattleState state) {
    _stateBuffer.add(state);
    if (!_isProcessing) _processStates();
  }

  void _processStates() async {
    _isProcessing = true;
    while (_stateBuffer.isNotEmpty) {
      final state = _stateBuffer.removeAt(0);
      setState(() {
        _visibleStates.add(state);
        _game.party = state.partySnapshot;
        _game.enemies = state.enemiesSnapshot;
      });
      WidgetsBinding.instance.addPostFrameCallback(_scrollToBottom);
      await Future.delayed(const Duration(milliseconds: 250));
    }
    _isProcessing = false;
  }

  void _nextRound() async {
    if (!_game.gameStarted) {
      _game.generateEncounter();
    }
    if (!_game.enemies.any((c) => c.isAlive)) {
      _game.goDeeper();
    }
    _visibleStates.add(
      BattleState(
        logMessage: '────────── Round ${_game.currentRound} ──────────',
        partySnapshot: _game.party,
        enemiesSnapshot: _game.enemies,
      ),
    );
    await _game.progressRound();
    _scrollToBottom(Duration.zero);
  }

  void _scrollToBottom(Duration _) {
    _logController.animateTo(
      _logController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
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
      _game = DungeonService(
        onStateUpdate: (msg) => setState(() => {}),
        onGameOver: () => setState(() {}),
      );
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
                child: Text(getSimulateText()),
                onPressed:
                    () => setState(() {
                      _nextRound();
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
            itemCount: _visibleStates.length,
            itemBuilder:
                (context, i) => ListTile(
                  title: Text(
                    _visibleStates[i].logMessage,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
          ),
        ),
      ],
    );
  }

  String getSimulateText() {
    if (!_game.gameStarted) {
      return "Delve";
    }
    if (!_game.enemies.any((c) => c.isAlive)) {
      return "Delve Deeper";
    }
    return "Fight";
  }
}
