import 'package:delve/Ability/effects.dart';
import 'package:delve/Ability/target_resolvers.dart';
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
}
