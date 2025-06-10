// character_detail_screen.dart
import 'package:delve/Character/character.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterDetailScreen extends ConsumerWidget {
  final Character character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    '${character.currentHealth}/${character.maxHealth}',
                  ),
                  _buildStatRow('Speed', character.speed.toString()),
                  _buildStatRow('Total Kills', character.totalKills.toString()),
                  _buildXPRow(),
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

  Widget _buildXPRow() {
    final progress =
        character.nextLevelXP > 0
            ? character.currentXP / character.nextLevelXP
            : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Center vertically
        children: [
          Text(
            'Level ${character.level}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 14),
          // Bar and XP as a flexible row
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
                  '${character.currentXP}/${character.nextLevelXP} XP',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
