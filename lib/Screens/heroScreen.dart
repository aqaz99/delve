import 'package:delve/Character/character.dart';
import 'package:delve/Character/character_repository.dart';
import 'package:flutter/material.dart';

class HeroScreen extends StatefulWidget {
  @override
  _HeroScreenState createState() => _HeroScreenState();
}

class _HeroScreenState extends State<HeroScreen> {
  final CharacterRepository _repo = CharacterRepository();
  late Future<List<Character>> _partyFuture;

  @override
  void initState() {
    super.initState();
    _partyFuture = _repo.loadParty();
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
      _partyFuture = _repo.loadParty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Party Members'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshParty),
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
                subtitle: Text('Level/Maxhealth ${character.maxHealth}'),
                trailing: Text('HP: ${character.currentHealth}'),
                onTap: () => _showCharacterDetails(character),
              );
            },
          );
        },
      ),
    );
  }
}
