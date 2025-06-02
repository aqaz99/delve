import 'package:delve/Screens/delveScreen.dart';
import 'package:delve/Screens/heroScreen.dart';
import 'package:delve/Screens/itemScreen.dart';
import 'package:flutter/material.dart';

void main() => runApp(DungeonApp());

class DungeonApp extends StatelessWidget {
  const DungeonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    final ThemeData theme = Theme.of(context);
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
            icon: Badge(child: Icon(Icons.notifications_sharp)),
            label: 'Characters',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Badge(label: Text('2'), child: Icon(Icons.messenger_sharp)),
            label: 'Messages',
          ),
        ],
      ),
      body: IndexedStack(index: currentPageIndex, children: _pages),
    );
  }
}
