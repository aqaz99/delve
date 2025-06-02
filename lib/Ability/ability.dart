// ability.dart
import 'package:delve/Ability/effects.dart';
import 'package:delve/Ability/target_resolvers.dart';
import 'package:delve/Character/character.dart';
import 'package:delve/enums.dart';

class Ability {
  final String name;
  final AbilityType type;
  final int scale;
  final TargetResolver targetResolver;
  final AbilityEffect effect;
  final int chance;

  Ability({
    required this.name,
    required this.type,
    required this.scale,
    required this.targetResolver,
    required this.effect,
    required this.chance,
  });

  String abilityUseText(Character caster, List<Character> targets) {
    String useText = "";

    switch (type) {
      case AbilityType.damage:
        useText =
            "${caster.name} uses $name on ${targets.map((t) => t.name).join(', ')} for $scale";
        break;
      case AbilityType.heal:
        useText =
            "${caster.name} heals ${targets.length == 1 && targets.first == caster ? 'self' : targets.map((t) => t.name).join(', ')} for $scale";
        break;
      case AbilityType.buff:
        break;
      case AbilityType.overTime:
        break;
    }
    return useText;
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'name': name,
  //     'type': type.name,
  //     'scale': scale,
  //     'targetResolver': _targetResolverToJson(targetResolver),
  //     'effect': _effectToJson(effect),
  //     'chance': chance,
  //   };
  // }

  // static Ability fromJson(Map<String, dynamic> json) {
  //   return Ability(
  //     name: json['name'],
  //     type: AbilityType.values.byName(json['type']),
  //     scale: json['scale'],
  //     targetResolver: _targetResolverFromJson(json['targetResolver']),
  //     effect: _effectFromJson(json['effect']),
  //     chance: json['chance'],
  //   );
  // }
}
