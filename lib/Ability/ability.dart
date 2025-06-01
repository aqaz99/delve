import 'package:delve/Ability/effects.dart';
import 'package:delve/Ability/target_resolvers.dart';
import 'package:delve/enums.dart';

class Ability {
  final String name;
  final AbilityType type;
  final List<int> validPositions;
  final int scale;
  final TargetResolver targetResolver;
  final AbilityEffect effect;

  Ability({
    required this.name,
    required this.type,
    required this.validPositions,
    required this.scale,
    required this.targetResolver,
    required this.effect,
  });

  bool canUseFromPosition(int position) => validPositions.contains(position);
}
