import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/seez_theme.dart';
import '../theme/app_theme.dart';
import 'mermaid_renderer.dart';

/// Viewer for standalone .mermaid files
/// Renders the mermaid diagram using WebView-based rendering
class MermaidFileViewer extends StatelessWidget {
  final String content;
  final String currentTheme;
  final String fileName;

  const MermaidFileViewer({
    super.key,
    required this.content,
    required this.currentTheme,
    required this.fileName,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // File Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _borderColor,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.account_tree_outlined,
                  size: 32,
                  color: _accentColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: GoogleFonts.oldStandardTt(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mermaid Diagram File',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: _textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: currentTheme == 'seez'
                        ? SeezTheme.pastelBlue
                        : AppTheme.primaryBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '.mermaid',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Rendered Diagram
          Container(
            decoration: BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _borderColor,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: MermaidRenderer(
                diagramCode: content,
                currentTheme: currentTheme,
                height: 600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
