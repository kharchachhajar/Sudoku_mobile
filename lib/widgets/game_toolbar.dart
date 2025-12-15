
// ============================================
// widgets/game_toolbar.dart
// ============================================
import 'package:flutter/material.dart';
import '../utils/constants.dart'; // li fih AppConstants

class GameToolbar extends StatelessWidget {
  final VoidCallback? onUndo;
  final VoidCallback onErase;
  final VoidCallback onNotes;
  final VoidCallback? onHint;
  final bool canUndo;
  final bool isNotesMode;

  const GameToolbar({
    Key? key,
    this.onUndo,
    required this.onErase,
    required this.onNotes,
    this.onHint,
    this.canUndo = false,
    this.isNotesMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildToolButton(
          icon: Icons.undo,
          label: 'Annuler',
          onPressed: canUndo ? onUndo : null,
          isActive: false,
        ),
        _buildToolButton(
          icon: Icons.backspace,
          label: 'Effacer',
          onPressed: onErase,
          isActive: false,
        ),
        _buildToolButton(
          icon: Icons.edit_note,
          label: 'Notes',
          onPressed: onNotes,
          isActive: isNotesMode,
        ),
        _buildToolButton(
          icon: Icons.lightbulb,
          label: 'Indice',
          onPressed: onHint,
          isActive: false,
        ),
      ],
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required bool isActive,
  }) {
    final color = onPressed == null
        ? Colors.grey.shade400
        : isActive
        ? AppConstants.primaryColor
        : Colors.grey.shade600;

    return InkWell(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? AppConstants.primaryColor.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}