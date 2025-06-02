import 'package:flutter/material.dart';

class ItemScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Items')),
      body: Center(
        child: Text(
          'Welcome to the Item Screen!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
