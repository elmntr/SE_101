import 'package:flutter/material.dart';

class ItemsPage extends StatelessWidget {
  const ItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    /*return Center(
      child: Text(
        "Items Screen",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );*/
    return Scaffold(
      body: const Center(
        child: Text(
          'This is the Items Page',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
