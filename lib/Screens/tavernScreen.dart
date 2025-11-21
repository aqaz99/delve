import 'package:delve/Screens/delveScreen.dart';
import 'package:delve/Screens/heroScreen.dart';
import 'package:delve/Screens/itemScreen.dart';
import 'package:flutter/material.dart';

class TavernScreen extends StatelessWidget {
  const TavernScreen({super.key});

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.brown[700]),
              const SizedBox(height: 12),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tavern')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildTile(
              context,
              icon: Icons.explore,
              label: 'Delve',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DelveScreen()),
                  ),
            ),
            _buildTile(
              context,
              icon: Icons.person_add,
              label: 'Recruit Heroes',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HeroScreen()),
                  ),
            ),
            _buildTile(
              context,
              icon: Icons.shopping_cart,
              label: 'Buy Items',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ItemScreen()),
                  ),
            ),
            _buildTile(
              context,
              icon: Icons.upgrade,
              label: 'Tavern Upgrades',
              onTap:
                  () => showDialog<void>(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          title: const Text('Tavern Upgrades'),
                          content: const Text(
                            'Coming soon — upgrades will be added here.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
