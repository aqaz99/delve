import 'package:delve/Item/item.dart';

final itemBoots = Item(
  name: 'Boots',
  description: 'Light boots that make you a bit quicker.',
  speedBonus: 1,
);

final itemRingOfVitality = Item(
  name: 'Ring of Vitality',
  description: 'A small ring that grants extra vitality.',
  maxHealthBonus: 10,
);

final itemAmulet = Item(
  name: 'Amulet of Swiftness',
  description: 'A magical amulet that grants speed.',
  speedBonus: 2,
);

final itemLeatherVest = Item(
  name: 'Leather Vest',
  description: 'Provides a small boost to health.',
  maxHealthBonus: 5,
);

final List<Item> allItems = [
  itemBoots,
  itemRingOfVitality,
  itemAmulet,
  itemLeatherVest,
];

Item getItemByName(String name) => allItems.firstWhere((i) => i.name == name);
