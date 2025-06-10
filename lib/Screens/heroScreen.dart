import 'package:delve/Character/character.dart';
import 'package:delve/Character/character_list.dart';
import 'package:delve/Screens/characterDetailScreen.dart';
import 'package:delve/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

class HeroScreen extends ConsumerWidget {
  const HeroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final party = ref.watch(partyProvider);
    List<Character> _generateNewParty() {
      final random = Random();
      final shuffled = List<Character>.from(allCharacters)..shuffle(random);
      return shuffled.take(3).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Party Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.healing),
            onPressed: () {
              ref.read(partyProvider.notifier).healParty(5);
            },
            tooltip: 'Heal Party (+5 HP)',
          ),
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () async {
              final newParty = _generateNewParty();
              ref.read(partyProvider.notifier).setParty(newParty);
              final partyService = ref.read(partyServiceProvider);
              await partyService.saveParty(newParty);
            },
            tooltip: 'Generate New Party',
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: party.length,
        itemBuilder: (context, index) {
          final character = party[index];
          return ListTile(
            title: Text(character.name),
            subtitle: Text(
              'Health: ${character.currentHealth}/${character.maxHealth}',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CharacterDetailScreen(character: character),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
