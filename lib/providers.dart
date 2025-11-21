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
    onStateUpdate: (state) {},
    onGameOver: () {},
  );
});

final enemyProvider = StateProvider<List<Character>>((ref) => []);
// App-wide current page index for the bottom navigation (0=Heroes,1=Home/Delve,2=Tavern,3=Items)
final currentPageProvider = StateProvider<int>((ref) => 1);
