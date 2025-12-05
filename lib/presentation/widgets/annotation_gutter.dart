import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/annotation.dart';

/// Left-hand vertical gutter showing annotation markers
class AnnotationGutter extends StatelessWidget {
  final List<Annotation> annotations;
  final String currentTheme;
  final Function(Annotation) onAnnotationTap;
  final double contentScrollOffset;
  final double contentHeight;

  const AnnotationGutter({
    super.key,
    required this.annotations,
    required this.currentTheme,
    required this.onAnnotationTap,
    this.contentScrollOffset = 0,
    this.contentHeight = 1000,
  });

  Color _getAnnotationColor(String color) {
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
    if (annotations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 60,
      decoration: BoxDecoration(
        color: currentTheme == 'seez'
            ? const Color(0xFFF5F0E8)
            : (currentTheme == 'dark'
                ? const Color(0xFF1E1E1E)
                : const Color(0xFFF8F8F8)),
        border: Border(
          right: BorderSide(
            color: currentTheme == 'seez'
                ? const Color(0xFFD4C5A9)
                : (currentTheme == 'dark'
                    ? const Color(0xFF3E3E3E)
                    : const Color(0xFFE0E0E0)),
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: annotations.length,
        itemBuilder: (context, index) {
          final annotation = annotations[index];
          final color = _getAnnotationColor(annotation.color);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Tooltip(
              message: '${annotation.anchorText}\n\n${annotation.content}',
              preferBelow: false,
              child: GestureDetector(
                onTap: () => onAnnotationTap(annotation),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: color.withValues(alpha: 0.6),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.bookmark_fill,
                          size: 20,
                          color: color,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${index + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                        if (annotation.lineNumber != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'L${annotation.lineNumber}',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
