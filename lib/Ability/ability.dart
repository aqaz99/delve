// ability.dart
import 'package:delve/Ability/effects.dart';
import 'package:delve/Ability/target_resolvers.dart';
import 'package:delve/Character/character.dart';
import 'package:delve/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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

  RichText abilityUseText(
    Character caster,
    List<Character> targets,
    bool isCasterAlly,
    bool isTargetAlly,
  ) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "${caster.name} ",
            style: TextStyle(color: isCasterAlly ? Colors.blue : Colors.red),
          ),
          TextSpan(text: "uses ", style: TextStyle(color: Colors.black)),
          TextSpan(text: "$name ", style: TextStyle(color: Colors.blueGrey)),
          TextSpan(text: "on ", style: TextStyle(color: Colors.black)),
          TextSpan(
            text: "${targets.map((t) => t.name).join(', ')} ",
            style: TextStyle(color: isTargetAlly ? Colors.blue : Colors.red),
          ),
          TextSpan(text: "for ", style: TextStyle(color: Colors.black)),
          TextSpan(
            text: "$scale",
            style: TextStyle(color: const Color.fromARGB(255, 160, 123, 2)),
          ),
        ],
      ),
    );
  }
}
