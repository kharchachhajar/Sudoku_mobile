
// ============================================
// widgets/number_pad.dart
// ============================================
import 'package:flutter/material.dart';
import '../utils/constants.dart'; // li fih AppConstants
import '../models/cell_model.dart';


class NumberPad extends StatelessWidget {
  final Function(int) onNumberTap;
  final List<List<CellModel>> grid;
  final bool showRemaining;

  const NumberPad({
    Key? key,
    required this.onNumberTap,
    required this.grid,
    this.showRemaining = true,
  }) : super(key: key);

  int _countNumber(int number) {
    int count = 0;
    for (var row in grid) {
      for (var cell in row) {
        if (cell.value == number) count++;
      }
    }
    return 9 - count;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(9, (index) {
        int number = index + 1;
        int remaining = _countNumber(number);
        bool isComplete = remaining == 0;

        return InkWell(
          onTap: isComplete ? null : () => onNumberTap(number),
          child: Container(
            width: 36,
            height: 50,
            decoration: BoxDecoration(
              color: isComplete ? Colors.grey.shade300 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isComplete
                    ? Colors.grey.shade400
                    : AppConstants.primaryColor,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isComplete
                        ? Colors.grey.shade500
                        : AppConstants.primaryColor,
                  ),
                ),
                if (showRemaining && !isComplete)
                  Text(
                    '$remaining',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}