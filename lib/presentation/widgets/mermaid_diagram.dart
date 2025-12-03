import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/seez_theme.dart';
import '../theme/app_theme.dart';
import 'mermaid_renderer.dart';

/// Widget for displaying Mermaid diagrams embedded in markdown
/// Uses WebView-based rendering with mermaid.js
class MermaidDiagram extends StatelessWidget {
  final String diagramCode;
  final String currentTheme;

  const MermaidDiagram({
    super.key,
    required this.diagramCode,
    required this.currentTheme,
  });

  Color get _backgroundColor {
    return currentTheme == 'seez'
        ? SeezTheme.lightBeigeGradient1
        : (currentTheme == 'dark'
            ? AppTheme.darkBackground
            : AppTheme.lighterBackground);
  }

  Color get _borderColor {
    return currentTheme == 'seez'
        ? SeezTheme.mediumBrownBorder
        : (currentTheme == 'dark'
            ? AppTheme.borderDark
            : AppTheme.border);
  }

  Color get _textColor {
    return currentTheme == 'seez'
        ? SeezTheme.darkBrownText
        : (currentTheme == 'dark'
            ? AppTheme.textOnDark
            : AppTheme.textPrimary);
  }

  Color get _accentColor {
    return currentTheme == 'seez'
        ? SeezTheme.primaryBrown
        : AppTheme.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _borderColor,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_tree_outlined,
                  size: 18,
                  color: _accentColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Mermaid Diagram',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: currentTheme == 'seez'
                        ? SeezTheme.pastelGreen
                        : AppTheme.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 12,
                        color: currentTheme == 'seez'
                            ? SeezTheme.primaryBrown
                            : AppTheme.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Rendered',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: _textColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Rendered Diagram
          MermaidRenderer(
            diagramCode: diagramCode,
            currentTheme: currentTheme,
          ),
        ],
      ),
    );
  }
}
