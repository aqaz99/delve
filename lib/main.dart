// main.dart
import 'package:delve/Screens/delveScreen.dart';
import 'package:delve/Screens/heroScreen.dart';
import 'package:delve/Screens/itemScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

void main() {
  runApp(ProviderScope(child: DungeonApp()));
}

class DungeonApp extends StatelessWidget {
  const DungeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Delve - Auto Battler')),
        body: DungeonGame(),
      ),
    );
  }
}

class DungeonGame extends StatefulWidget {
  const DungeonGame({super.key});

  @override
  _DungeonGameState createState() => _DungeonGameState();
}

class _DungeonGameState extends State<DungeonGame> {
  int currentPageIndex = 1;
  final List<Widget> _pages = [
    HeroScreen(),
    DelveScreen(), // Home screen
    ItemScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
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
            label: 'Home',
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
