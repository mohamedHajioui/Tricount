import 'package:flutter/material.dart';
import '../widgets/tricound_card.dart'; // Import your widget


class TricountListPage extends StatelessWidget {
  final List<Map<String, dynamic>> tricounts = [
    {
      'title': 'Trip to Paris',
    },
    {
      'title': 'BBQ Party',
    },
    {
      'title': 'Groceries',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My lklklkl')),
      
      body: ListView(
        children: tricounts.map((t) {
          return TricountCard(
            title: t['title'],
          );
        }).toList(),
      ),
    );
  }
}
