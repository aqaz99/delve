class Item {
  final String name;
  final String description;
  final int speedBonus;
  final int maxHealthBonus;

  Item({
    required this.name,
    this.description = '',
    this.speedBonus = 0,
    this.maxHealthBonus = 0,
  });

  Item copyWith({
    String? name,
    String? description,
    int? speedBonus,
    int? maxHealthBonus,
  }) {
    return Item(
      name: name ?? this.name,
      description: description ?? this.description,
      speedBonus: speedBonus ?? this.speedBonus,
      maxHealthBonus: maxHealthBonus ?? this.maxHealthBonus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'speedBonus': speedBonus,
      'maxHealthBonus': maxHealthBonus,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      description: json['description'] ?? '',
      speedBonus: json['speedBonus'] ?? 0,
      maxHealthBonus: json['maxHealthBonus'] ?? 0,
    );
  }
}
