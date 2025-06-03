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
  late Future<List<Character>> _loadPartyFuture;
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
    _loadPartyFuture = _game.loadDungeonParty();
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
      await Future.delayed(const Duration(milliseconds: 750));
    }
    _isProcessing = false;
  }

  // I think the final state is being shown and then the states from the beginning display

  void _delve() async {
    if (!_game.gameStarted) {
      _game.generateEncounter();
    }
    if (!_game.enemies.any((c) => c.isAlive)) {
      _game.goDeeper();
    }
    // _visibleStates.clear();
    await _game.progressRound();
    _scrollToBottom(Duration.zero);
  }

  void _scrollToBottom(Duration _) {
    _logController.animateTo(
      _logController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 750),
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
    return FutureBuilder<void>(
      future: _loadPartyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading party: ${snapshot.error}'));
        } else {
          return Column(
            children: [
              // Controls
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      child: Text(getDelveText()),
                      onPressed:
                          () => setState(() {
                            _game.enemies.any((c) => c.isAlive)
                                ? null
                                : _delve();
                          }),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _resetGame,
                      child: const Text('Reset'),
                    ),
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
                        if (_game.gameStarted)
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
                      (context, i) =>
                          ListTile(title: _visibleStates[i].logMessage),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  String getDelveText() {
    if (!_game.gameStarted) {
      return "Delve";
    }
    if (!_game.enemies.any((c) => c.isAlive)) {
      return "Delve Deeper";
    }
    return "Fight";
  }
}
