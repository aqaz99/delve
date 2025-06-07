import 'package:delve/Battle/battle_service.dart';
import 'package:delve/Dungeon/dungeon_service.dart';
import 'package:delve/Character/character.dart';
import 'package:delve/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DelveScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<DelveScreen> createState() => _DelveScreenState();
}

class _DelveScreenState extends ConsumerState<DelveScreen> {
  late DungeonService _game;
  late Future<void> _loadProgressFuture;
  final List<BattleState> _stateBuffer = [];
  final List<BattleState> _visibleStates = [];
  bool _isProcessing = false;
  final _logController = ScrollController();

  @override
  void initState() {
    super.initState();
    _game = DungeonService(
      partyService: ref.read(partyServiceProvider),
      onStateUpdate: _handleNewState,
      onGameOver: () {
        print("Game over");
      },
    );
    _loadProgressFuture = _game.loadProgress(ref);
  }

  void _handleNewState(BattleState state) {
    ref.read(partyProvider.notifier).setParty(state.partySnapshot);
    _stateBuffer.add(state);
    if (!_isProcessing) _processStates();
  }

  void _processStates() async {
    _isProcessing = true;
    while (_stateBuffer.isNotEmpty) {
      final state = _stateBuffer.removeAt(0);
      setState(() => _visibleStates.add(state));
      WidgetsBinding.instance.addPostFrameCallback(_scrollToBottom);
    }
    _isProcessing = false;
  }

  void _delve() async {
    if (!_game.gameStarted) _game.generateEncounter(ref);
    if (!_game.enemies.any((c) => c.isAlive)) _game.goDeeper(ref);

    await _game.progressRound(ref);
    _scrollToBottom(Duration.zero);
  }

  void _resetDelveState() async {
    await _game.clearDungeonRun(ref);
    _visibleStates.clear();
    _stateBuffer.clear();
    ref.read(partyProvider.notifier).healParty(100);
    _scrollToBottom(Duration.zero);
  }

  void _scrollToBottom(Duration _) {
    _logController.animateTo(
      _logController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
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

  @override
  Widget build(BuildContext context) {
    final party = ref.watch(partyProvider);
    return FutureBuilder<void>(
      future: _loadProgressFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (party.any((c) => c.isAlive))
                  ElevatedButton(
                    onPressed: _delve,
                    child: Text(
                      _game.enemies.any((c) => c.isAlive)
                          ? "Fight"
                          : "Delve ${_game.depth}",
                    ),
                  ),
                if (!party.any((c) => c.isAlive))
                  ElevatedButton(
                    onPressed: _resetDelveState,
                    child: Text("Reset"),
                  ),
              ],
            ),
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
                      _buildTeamPanel('Party', party),
                      if (_game.gameStarted)
                        _buildTeamPanel('Enemies', _game.enemies),
                    ],
                  ),
                ],
              ),
            ),
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
      },
    );
  }
}
