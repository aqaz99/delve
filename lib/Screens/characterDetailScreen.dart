// character_detail_screen.dart
import 'package:delve/Character/character.dart';
import 'package:delve/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterDetailScreen extends ConsumerWidget {
  final Character character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Always pull the latest character state from the party provider so
    // UI reflects changes (like spending ability points) made via the
    // PartyNotifier. We match by name; if not found fall back to the
    // original passed-in character.
    final party = ref.watch(partyProvider);
    final currentCharacter = party.firstWhere(
      (c) => c.name == character.name,
      orElse: () => character,
    );
    final mockItems = [
      'Iron Sword',
      'Leather Armor',
      'Health Potion',
      'Mana Ring',
      'Traveler\'s Boots',
    ];

    return Scaffold(
      appBar: AppBar(title: Text(character.name)),
      body: Column(
        children: [
          // Character Stats and Equipment Slots
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatRow(
                    'Health',
                    '${currentCharacter.currentHealth}/${currentCharacter.maxHealth}',
                  ),
                  _buildStatRow('Speed', currentCharacter.speed.toString()),
                  _buildStatRow(
                    'Total Kills',
                    currentCharacter.totalKills.toString(),
                  ),
                  _buildXPRow(currentCharacter),
                  const SizedBox(height: 20),
                  _buildAbilityPointsSection(
                    ref,
                    currentCharacter,
                  ), // New section for ability points
                  const SizedBox(height: 20),
                  const Text('Equipment Slots', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  _buildEquipmentSlots(),
                ],
              ),
            ),
          ),

          // Inventory Items List
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(),
              ),
              child: ListView.builder(
                itemCount: mockItems.length,
                itemBuilder:
                    (context, index) => _buildInventoryItem(mockItems[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildEquipmentSlots() {
    const slotTypes = ['Head', 'Chest', 'Hands', 'Legs', 'Feet', 'Main Hand'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: slotTypes.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              slotTypes[index],
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInventoryItem(String itemName) {
    return ListTile(
      title: Text(itemName),
      trailing: const Icon(Icons.drag_handle),
      onTap: () {},
    );
  }

  Widget _buildXPRow(Character c) {
    final progress = c.nextLevelXP > 0 ? c.currentXP / c.nextLevelXP : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Level ${c.level}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 11,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.green[400]!,
                      ),
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${c.currentXP}/${c.nextLevelXP} XP',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbilityPointsSection(WidgetRef ref, Character c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ability Points: ${c.abilityPoints}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        c.abilityPoints > 0
            ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed:
                      c.abilityPoints > 0
                          ? () {
                            ref
                                .read(partyProvider.notifier)
                                .updateCharacter(
                                  c.copyWith(
                                    maxHealth: c.maxHealth + 5,
                                    currentHealth: c.maxHealth + 5,
                                    abilityPoints: c.abilityPoints - 1,
                                  ),
                                );
                          }
                          : null,
                  child: const Text('+ Health'),
                ),
                ElevatedButton(
                  onPressed:
                      c.abilityPoints > 0
                          ? () {
                            ref
                                .read(partyProvider.notifier)
                                .updateCharacter(
                                  c.copyWith(
                                    speed: c.speed + 1,
                                    abilityPoints: c.abilityPoints - 1,
                                  ),
                                );
                          }
                          : null,
                  child: const Text('+ Speed'),
                ),
              ],
            )
            : Container(),
      ],
    );
  }
}
