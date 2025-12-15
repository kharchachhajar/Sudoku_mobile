//widgets/best_tome_card.dart
import 'package:flutter/material.dart';

class BestTimeCard extends StatelessWidget {
  final String difficulty;
  final String time;
  final int score;
  final Color color;

  const BestTimeCard({
    Key? key,
    required this.difficulty,
    required this.time,
    required this.score,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: const Icon(Icons.timer, color: Colors.white),
        ),
        title: Text(difficulty),
        subtitle: Text('Score: $score'),
        trailing: Text(
          time,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}
