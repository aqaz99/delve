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
    _processState();
  }

  void _processState() async {
    final state = _stateBuffer.removeAt(0);
    setState(() => _visibleStates.add(state));
    WidgetsBinding.instance.addPostFrameCallback(_scrollToBottom);
    _isProcessing = !state.battleOver;
  }

  void _delve() async {
    if (!_game.gameStarted) _game.generateEncounter(ref);
    if (!_game.enemies.any((c) => c.isAlive)) _game.goDeeper(ref);

    await _game.progressRound(ref);
    _scrollToBottom(Duration.zero);
  }

  void _resetDelveState({bool resetHealth = true}) async {
    await _game.clearDungeonRun(ref);
    _visibleStates.clear();
    _stateBuffer.clear();
    if (resetHealth) {
      ref.read(partyProvider.notifier).healParty(100);
    }
    _scrollToBottom(Duration.zero);
    _isProcessing = false;
  }

  void _scrollToBottom(Duration _) {
    if (_logController.hasClients) {
      _logController.animateTo(
        _logController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
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

  Widget _buildEventOptions(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Special Event at Depth ${_game.depth}!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _game.handleEventChoice(ref, 'rest');
            _game.saveProgress(ref);
            setState(() {});
          },
          child: const Text('Rest (+10 HP to All)'),
        ),
        ElevatedButton(
          onPressed: () {
            _game.handleEventChoice(ref, 'loot');
            _game.saveProgress(ref);
            setState(() {});
          },
          child: const Text('Search for loot'),
        ),
        ElevatedButton(
          onPressed: () {
            _game.handleEventChoice(ref, 'escape');
            _resetDelveState(resetHealth: true);
            _game.gameStarted = false;
            _game.saveProgress(ref);
            Navigator.of(context).pop();
            setState(() {});
          },
          child: const Text('Escape with what you have'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final party = ref.watch(partyProvider);
    return Scaffold(
      appBar: AppBar(title: Text('Delve')),
      body: FutureBuilder<void>(
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
                      onPressed: _isProcessing ? null : _delve,
                      child: Text("Delve"),
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
                        Expanded(child: _buildTeamPanel('Party', party)),
                        if (_game.gameStarted && !_game.showEvent)
                          Expanded(
                            child: _buildTeamPanel('Enemies', _game.enemies),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child:
                    _game.showEvent
                        ? _buildEventOptions(context)
                        : ListView.builder(
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
      ),
    );
  }
}
