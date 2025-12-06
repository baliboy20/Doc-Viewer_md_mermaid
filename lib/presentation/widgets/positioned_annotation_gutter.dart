import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/annotation.dart';

/// Annotation gutter that shows badges as a vertical list at the top
class PositionedAnnotationGutter extends StatelessWidget {
  final List<Annotation> annotations;
  final String currentTheme;
  final Function(Annotation) onAnnotationTap;
  final int totalLines;
  final double lineHeight;
  final double topPadding;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const PositionedAnnotationGutter({
    super.key,
    required this.annotations,
    required this.currentTheme,
    required this.onAnnotationTap,
    required this.totalLines,
    required this.isCollapsed,
    required this.onToggleCollapse,
    this.lineHeight = 24.0, // Not used in list mode
    this.topPadding = 24.0,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isCollapsed ? 24 : 30,
      decoration: BoxDecoration(
        color: isCollapsed
            ? Colors.transparent
            : (currentTheme == 'seez'
                ? const Color(0xFFF5F0E8)
                : (currentTheme == 'dark'
                    ? const Color(0xFF1E1E1E)
                    : const Color(0xFFF8F8F8))),
        border: isCollapsed
            ? null
            : Border(
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
      child: Column(
        children: [
          // Collapse/expand button at the top
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: IconButton(
              icon: Icon(
                isCollapsed
                    ? CupertinoIcons.chevron_right
                    : CupertinoIcons.chevron_left,
                size: 12,
                color: currentTheme == 'seez'
                    ? const Color(0xFF8B7355)
                    : (currentTheme == 'dark'
                        ? const Color(0xFFB0B0B0)
                        : const Color(0xFF757575)),
              ),
              iconSize: 12,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onToggleCollapse,
              tooltip: isCollapsed ? 'Show annotations' : 'Hide annotations',
            ),
          ),

          // Annotation badges list
          if (!isCollapsed && annotations.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
                itemCount: annotations.length,
                itemBuilder: (context, index) {
                  final annotation = annotations[index];
                  final color = _getAnnotationColor(annotation.color);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Tooltip(
                      message: annotation.anchorText,
                      preferBelow: false,
                      waitDuration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: currentTheme == 'dark'
                            ? const Color(0xFF2D2D2D)
                            : const Color(0xFF424242),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: color.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      textStyle: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: GestureDetector(
                        onTap: () => onAnnotationTap(annotation),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.bookmark,
                                size: 14,
                                color: color,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '${index + 1}',
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
