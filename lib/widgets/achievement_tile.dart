//widgets/acheivement_tile.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AchievementTile extends StatelessWidget {
  final String title;
  final bool achieved;
  final String description;

  const AchievementTile({
    Key? key,
    required this.title,
    required this.achieved,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        achieved ? Icons.check_circle : Icons.circle_outlined,
        color: achieved ? AppConstants.facileDifficultyColor : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: achieved ? FontWeight.bold : FontWeight.normal,
          color: achieved ? Colors.black : Colors.grey,
        ),
      ),
      subtitle: Text(description),
    );
  }
}
