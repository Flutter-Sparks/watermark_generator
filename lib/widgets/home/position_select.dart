import 'package:flutter/material.dart';
import 'package:watermark_generator/widgets/decorated_container.dart';

class PositionSelect extends StatelessWidget {
  final List<AlignmentGeometry> positions;
  final AlignmentGeometry selectedPosition;
  final Function(AlignmentGeometry) onSelect;
  const PositionSelect({
    super.key,
    required this.positions,
    required this.selectedPosition,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    Widget positionWidget(AlignmentGeometry e) {
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
          onTap: () {
            onSelect(e);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            decoration: BoxDecoration(
                border: selectedPosition == e
                    ? Border.all(color: Colors.black)
                    : null,
                color: selectedPosition == e
                    ? Colors.black.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(1000)),
            child: Text(
              e.toString().split(".")[1].toUpperCase(),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      selectedPosition == e ? Colors.black : Colors.grey[600],
                  letterSpacing: 1),
            ),
          ),
        ),
      );
    }

    return DecoratedContainer(
      child: Wrap(
        children: positions.map((e) => positionWidget(e)).toList(),
      ),
    );
  }
}
