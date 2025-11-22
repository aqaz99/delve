import 'package:delve/enums.dart';

class Item {
  final String name;
  final String description;
  final int speedBonus;
  final int maxHealthBonus;
  final ItemSlot slot;

  Item({
    required this.name,
    this.description = '',
    this.speedBonus = 0,
    this.maxHealthBonus = 0,
    required this.slot,
  });

  Item copyWith({
    String? name,
    String? description,
    int? speedBonus,
    int? maxHealthBonus,
    ItemSlot? slot,
  }) {
    return Item(
      name: name ?? this.name,
      description: description ?? this.description,
      speedBonus: speedBonus ?? this.speedBonus,
      maxHealthBonus: maxHealthBonus ?? this.maxHealthBonus,
      slot: slot ?? this.slot,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'speedBonus': speedBonus,
      'maxHealthBonus': maxHealthBonus,
      'slot': slot.name,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      description: json['description'] ?? '',
      speedBonus: json['speedBonus'] ?? 0,
      maxHealthBonus: json['maxHealthBonus'] ?? 0,
      slot: ItemSlot.values.firstWhere(
        (s) => s.name == (json['slot'] ?? 'mainHand'),
      ),
    );
  }
}
