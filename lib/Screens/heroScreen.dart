// heroScreen.dart
import 'package:delve/Character/character.dart';
import 'package:delve/Party/party_service.dart';
import 'package:flutter/material.dart';

class HeroScreen extends StatefulWidget {
  @override
  _HeroScreenState createState() => _HeroScreenState();
}

class _HeroScreenState extends State<HeroScreen> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshParty();
    }
  }

  final PartyService _partyService = PartyService();
  late Future<List<Character>> _partyFuture;

  Future<void> _saveDebugParty() async {
    final party = await _partyFuture;
    await _partyService.saveParty(party);
    _refreshParty();
  }

  Future<void> _clearSavedData() async {
    await _partyService.clearSavedParty();
    _refreshParty();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _partyFuture = _partyService.loadParty();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _showCharacterDetails(Character character) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  character.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'Health: ${character.currentHealth}/${character.maxHealth}',
                ),
                Text('Speed: ${character.speed}'),
                const SizedBox(height: 10),
                const Text('Abilities:'),
                ...character.abilities.map(
                  (a) => Text('- ${a.name}: ${a.effect}'),
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _refreshParty() async {
    setState(() {
      _partyFuture = _partyService.loadParty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Party Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDebugParty,
            tooltip: 'Save Default Party',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearSavedData,
            tooltip: 'Clear Saved Data',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshParty,
            tooltip: 'Reload Data',
          ),
        ],
      ),
      body: FutureBuilder<List<Character>>(
        future: _partyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final party = snapshot.data ?? [];

          return ListView.builder(
            itemCount: party.length,
            itemBuilder: (context, index) {
              final character = party[index];
              return ListTile(
                title: Text(character.name),
                subtitle: Text(
                  'Health: ${character.currentHealth}/${character.maxHealth}',
                ),
                trailing: Text('Delving: ${character.currentlyDelving}'),
                onTap: () => _showCharacterDetails(character),
              );
            },
          );
        },
      ),
    );
  }
}
