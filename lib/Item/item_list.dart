import 'package:delve/Item/item.dart';
import 'package:delve/enums.dart';

final itemBoots = Item(
  name: 'Traveler\'s Boots',
  description: 'Light boots that make you a bit quicker.',
  speedBonus: 1,
  slot: ItemSlot.feet,
);

final itemRingOfVitality = Item(
  name: 'Ring of Vitality',
  description: 'A small ring that grants extra vitality.',
  maxHealthBonus: 10,
  slot: ItemSlot.hands,
);

final itemAmulet = Item(
  name: 'Amulet of Swiftness',
  description: 'A magical amulet that grants speed.',
  speedBonus: 2,
  slot: ItemSlot.head,
);

final itemLeatherVest = Item(
  name: 'Leather Vest',
  description: 'Provides a small boost to health.',
  maxHealthBonus: 5,
  slot: ItemSlot.chest,
);

final List<Item> allItems = [
  itemBoots,
  itemRingOfVitality,
  itemAmulet,
  itemLeatherVest,
];

Item getItemByName(String name) => allItems.firstWhere((i) => i.name == name);
