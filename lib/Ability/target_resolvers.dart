import 'package:delve/character.dart';

abstract class TargetResolver {
  List<Character> resolve({
    required Character caster,
    required List<Character> allies,
    required List<Character> enemies,
  });
}

class RandomEnemyResolver extends TargetResolver {
  final int count;
  RandomEnemyResolver(this.count);

  @override
  List<Character> resolve({
    required Character caster,
    required List<Character> allies,
    required List<Character> enemies,
  }) {
    final validTargets = enemies.where((e) => e.isAlive).toList();
    validTargets.shuffle();
    return validTargets.take(count).toList();
  }
}

class FrontEnemyResolver extends TargetResolver {
  @override
  List<Character> resolve({
    required Character caster,
    required List<Character> allies,
    required List<Character> enemies,
  }) {
    return enemies.where((e) => e.isAlive).take(1).toList();
  }
}

class LowestHealthAllyResolver extends TargetResolver {
  final int count;

  LowestHealthAllyResolver(this.count);

  @override
  List<Character> resolve({
    required Character caster,
    required List<Character> allies,
    required List<Character> enemies,
  }) {
    final validTargets = allies.where((a) => a.isAlive).toList();

    validTargets.sort((a, b) => a.currentHealth.compareTo(b.currentHealth));

    return validTargets.take(count).toList();
  }
}
