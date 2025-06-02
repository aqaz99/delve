import 'package:delve/Ability/effects.dart';
import 'package:delve/Ability/target_resolvers.dart';
import 'package:delve/character.dart';
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
        List<String> targetNames = [];
        List<Character> localTargets = targets;
        for (var target in localTargets) {
          if (target.currentHealth - scale <= 0) {
            targetNames.add("${target.name}(Dead)");
          } else {
            targetNames.add(target.name);
          }
        }
        useText =
            "${caster.name} uses $name on ${targetNames.join(', ')} for $scale";
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
}
