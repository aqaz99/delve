import 'package:flutter/material.dart';

class HeroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Heroes')),
      body: Center(
        child: Text(
          'Welcome to the Hero Screen!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
