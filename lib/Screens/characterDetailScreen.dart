// character_detail_screen.dart
import 'package:delve/Character/character.dart';
import 'package:delve/providers.dart';
import 'package:delve/Item/item.dart';
import 'package:delve/Item/item_list.dart';
import 'package:delve/enums.dart';
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Constrain the scrollable area to the available height so
                // children that want to expand will not cause overflow.
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatRow(
                            'Health',
                            '${currentCharacter.currentHealth}/${currentCharacter.maxHealth}',
                          ),
                          _buildStatRow(
                            'Speed',
                            currentCharacter.speed.toString(),
                          ),
                          _buildStatRow(
                            'Total Kills',
                            currentCharacter.totalKills.toString(),
                          ),
                          _buildXPRow(currentCharacter),
                          const SizedBox(height: 10),
                          _buildAbilityPointsSection(
                            ref,
                            currentCharacter,
                          ), // New section for ability points
                          const SizedBox(height: 20),
                          const Text(
                            'Equipment Slots',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.22,
                            child: _buildEquipmentSlots(
                              context,
                              ref,
                              currentCharacter,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
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

  Widget _buildEquipmentSlots(
    BuildContext context,
    WidgetRef ref,
    Character currentCharacter,
  ) {
    final slots = ItemSlot.values;

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final equipped = currentCharacter.equippedItems[slot];
        return InkWell(
          onTap: () => _showEquipSheet(context, ref, currentCharacter, slot),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _prettySlotName(slot),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    equipped?.name ?? 'Empty',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _prettySlotName(ItemSlot slot) {
    final raw = slot.name; // e.g. 'mainHand'
    if (raw == 'mainHand') return 'Main Hand';
    return raw[0].toUpperCase() + raw.substring(1);
  }

  void _showEquipSheet(
    BuildContext context,
    WidgetRef ref,
    Character character,
    ItemSlot slot,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final candidates = allItems.where((i) => i.slot == slot).toList();
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Unequip'),
                onTap: () {
                  final updatedMap = Map<ItemSlot, Item?>.from(
                    character.equippedItems,
                  );
                  updatedMap[slot] = null;
                  final updated = character.copyWith(equippedItems: updatedMap);
                  ref.read(partyProvider.notifier).updateCharacter(updated);
                  Navigator.of(ctx).pop();
                },
              ),
              const Divider(),
              if (candidates.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No items available for this slot.'),
                )
              else
                ...candidates.map(
                  (item) => ListTile(
                    title: Text(item.name),
                    subtitle:
                        item.description.isNotEmpty
                            ? Text(item.description)
                            : null,
                    onTap: () {
                      final updatedMap = Map<ItemSlot, Item?>.from(
                        character.equippedItems,
                      );
                      updatedMap[slot] = item;
                      // Keep currentHealth within new effective max
                      final updated = character.copyWith(
                        equippedItems: updatedMap,
                      );
                      final cappedHealth = updated.currentHealth.clamp(
                        0,
                        updated.effectiveMaxHealth,
                      );
                      final finalUpdated = updated.copyWith(
                        currentHealth: cappedHealth,
                      );
                      ref
                          .read(partyProvider.notifier)
                          .updateCharacter(finalUpdated);
                      Navigator.of(ctx).pop();
                    },
                  ),
                ),
            ],
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
    return c.abilityPoints > 0 && !c.currentlyDelving
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ability Points: ${c.abilityPoints} ${c.currentlyDelving}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Row(
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
            ),
          ],
        )
        : Container();
  }
}
