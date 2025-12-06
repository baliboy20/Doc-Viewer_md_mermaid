import 'package:flutter/cupertino.dart';

/// Visual indicator for an annotation (sticky note marker)
class AnnotationIndicator extends StatelessWidget {
  final String annotationId;
  final String color;
  final VoidCallback onTap;

  const AnnotationIndicator({
    super.key,
    required this.annotationId,
    required this.color,
    required this.onTap,
  });

  Color get _indicatorColor {
    switch (color.toLowerCase()) {
      case 'yellow':
        return const Color(0xFFFFD700);
      case 'red':
        return const Color(0xFFFF6B6B);
      case 'blue':
        return const Color(0xFF4ECDC4);
      case 'green':
        return const Color(0xFF95E1D3);
      case 'orange':
        return const Color(0xFFFFAA5A);
      case 'purple':
        return const Color(0xFFB695F8);
      default:
        return const Color(0xFFFFD700);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _indicatorColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _indicatorColor,
              width: 1.5,
            ),
          ),
          child: Icon(
            CupertinoIcons.bookmark_fill,
            size: 16,
            color: _indicatorColor.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
