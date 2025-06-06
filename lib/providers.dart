import 'package:delve/Character/character.dart';
import 'package:delve/Dungeon/dungeon_service.dart';
import 'package:delve/Party/party_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final partyServiceProvider = Provider((ref) => PartyService());
final partyProvider = StateNotifierProvider<PartyNotifier, List<Character>>((
  ref,
) {
  return PartyNotifier(ref.read(partyServiceProvider));
});

final dungeonServiceProvider = Provider<DungeonService>((ref) {
  return DungeonService(
    partyService: ref.read(partyServiceProvider),
    onStateUpdate: (state) {}, // Implement in screen
    onGameOver: () {}, // Implement in screen
  );
});

final enemyProvider = StateProvider<List<Character>>((ref) => []);
