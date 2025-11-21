// main.dart
import 'package:delve/Screens/delveScreen.dart';
import 'package:delve/Screens/heroScreen.dart';
import 'package:delve/Screens/itemScreen.dart';
import 'package:delve/Screens/tavernScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:delve/providers.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

void main() {
  runApp(ProviderScope(child: DungeonApp()));
}

class DungeonApp extends StatelessWidget {
  const DungeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: DungeonGame());
  }
}

class DungeonGame extends ConsumerStatefulWidget {
  const DungeonGame({super.key});

  @override
  ConsumerState<DungeonGame> createState() => _DungeonGameState();
}

class _DungeonGameState extends ConsumerState<DungeonGame> {
  final List<Widget> _pages = [
    HeroScreen(),
    TavernScreen(), // Tavern screen
    ItemScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentPageIndex = ref.watch(currentPageProvider);

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          ref.read(currentPageProvider.notifier).state = index;
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Characters',
          ),

          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Tavern',
          ),
          NavigationDestination(
            icon: Icon(RpgAwesome.helmet), // Icon resembling a chest
            label: 'Items',
          ),
        ],
      ),
      body: IndexedStack(index: currentPageIndex, children: _pages),
    );
  }
}
