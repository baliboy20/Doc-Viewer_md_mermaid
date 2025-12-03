import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import '../../domain/entities/markdown_style_preferences.dart';
import '../theme/seez_theme.dart';
import '../theme/app_theme.dart';
import 'mermaid_diagram.dart';

/// Markdown viewer with custom styling and code highlighting
class MarkdownViewer extends StatelessWidget {
  final String content;
  final MarkdownStylePreferences stylePreferences;
  final String currentTheme;

  const MarkdownViewer({
    super.key,
    required this.content,
    required this.stylePreferences,
    required this.currentTheme,
  });

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
    return MarkdownBody(
      data: content,
      selectable: true,
      styleSheet: _buildMarkdownStyleSheet(context),
      onTapLink: (text, href, title) {
        if (href != null) {
          _launchUrl(href);
        }
      },
      builders: {
        'code': CodeElementBuilder(
          currentTheme: currentTheme,
          stylePreferences: stylePreferences,
        ),
      },
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet(BuildContext context) {
    final baseTextStyle = GoogleFonts.inter(
      fontSize: stylePreferences.baseFontSize,
      height: 1.6,
      letterSpacing: 0.2,
      color: _textColor,
    );

    return MarkdownStyleSheet(
      // Headers - Using Old Standard TT for Seez theme
      h1: (currentTheme == 'seez'
              ? GoogleFonts.oldStandardTt()
              : GoogleFonts.inter())
          .copyWith(
        fontSize: stylePreferences.h1FontSize,
        fontWeight: FontWeight.w400,
        color: _textColor,
        height: 1.3,
      ),

      h2: (currentTheme == 'seez'
              ? GoogleFonts.oldStandardTt()
              : GoogleFonts.inter())
          .copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: _accentColor,
        height: 1.3,
      ),

      h3: (currentTheme == 'seez'
              ? GoogleFonts.oldStandardTt()
              : GoogleFonts.inter())
          .copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: _accentColor,
        height: 1.4,
      ),

      h4: baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _textColor,
      ),

      h5: baseTextStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _textColor,
      ),

      h6: baseTextStyle.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _textColor.withValues(alpha: 0.8),
      ),

      // Body text
      p: baseTextStyle,

      // Strong/Bold - Custom styling with mediumBrownBorder color
      strong: baseTextStyle.copyWith(
        color: currentTheme == 'seez'
            ? SeezTheme.mediumBrownBorder
            : _accentColor,
        fontWeight: FontWeight.w600,
        fontSize: stylePreferences.baseFontSize - 1,
      ),

      // Emphasis/Italic
      em: baseTextStyle.copyWith(
        fontStyle: FontStyle.italic,
      ),

      // Code (inline)
      code: GoogleFonts.jetBrainsMono(
        fontSize: stylePreferences.codeFontSize,
        backgroundColor: currentTheme == 'seez'
            ? SeezTheme.lightCreamTile
            : (currentTheme == 'dark'
                ? AppTheme.darkBackground
                : AppTheme.lighterBackground),
        color: currentTheme == 'seez'
            ? SeezTheme.subtitleBrown
            : (currentTheme == 'dark'
                ? AppTheme.textOnDark
                : AppTheme.textPrimary),
      ),

      // Code blocks
      codeblockDecoration: BoxDecoration(
        color: currentTheme == 'seez'
            ? SeezTheme.lightBeigeGradient1
            : (currentTheme == 'dark'
                ? AppTheme.darkBackground
                : AppTheme.lighterBackground),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: currentTheme == 'seez'
              ? SeezTheme.mediumBrownBorder
              : (currentTheme == 'dark'
                  ? AppTheme.borderDark
                  : AppTheme.border),
          width: 1,
        ),
      ),

      // Lists
      listBullet: baseTextStyle.copyWith(
        color: _accentColor,
      ),

      // Blockquotes
      blockquote: baseTextStyle.copyWith(
        color: _textColor.withValues(alpha: 0.7),
        fontStyle: FontStyle.italic,
      ),

      blockquoteDecoration: BoxDecoration(
        color: currentTheme == 'seez'
            ? SeezTheme.lightCreamTile
            : (currentTheme == 'dark'
                ? AppTheme.darkBackground.withValues(alpha: 0.5)
                : AppTheme.lighterBackground),
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(
            color: _accentColor,
            width: 4,
          ),
        ),
      ),

      // Links
      a: baseTextStyle.copyWith(
        color: currentTheme == 'seez'
            ? SeezTheme.subtitleBlue
            : AppTheme.primaryBlue,
        decoration: TextDecoration.underline,
      ),

      // Horizontal Rules - Adjustable thickness
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: (currentTheme == 'seez'
                    ? SeezTheme.mediumBrownBorder
                    : (currentTheme == 'dark'
                        ? AppTheme.borderDark
                        : AppTheme.divider))
                .withValues(alpha: 0.3),
            width: stylePreferences.hrThickness,
          ),
        ),
      ),

      // Tables
      tableHead: baseTextStyle.copyWith(
        fontWeight: FontWeight.w600,
        color: _textColor,
      ),

      tableBody: baseTextStyle,

      tableBorder: TableBorder.all(
        color: currentTheme == 'seez'
            ? SeezTheme.mediumBrownBorder
            : (currentTheme == 'dark'
                ? AppTheme.borderDark
                : AppTheme.border),
        width: 1,
      ),

      // Spacing
      h1Padding: const EdgeInsets.only(top: 24, bottom: 16),
      h2Padding: const EdgeInsets.only(top: 20, bottom: 12),
      h3Padding: const EdgeInsets.only(top: 16, bottom: 10),
      h4Padding: const EdgeInsets.only(top: 14, bottom: 8),
      h5Padding: const EdgeInsets.only(top: 12, bottom: 6),
      h6Padding: const EdgeInsets.only(top: 10, bottom: 6),
      pPadding: const EdgeInsets.only(bottom: 16),
      listIndent: 24,
      blockquotePadding: const EdgeInsets.all(16),
      codeblockPadding: const EdgeInsets.all(16),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// Custom builder for code blocks with syntax highlighting
class CodeElementBuilder extends MarkdownElementBuilder {
  final String currentTheme;
  final MarkdownStylePreferences stylePreferences;

  CodeElementBuilder({
    required this.currentTheme,
    required this.stylePreferences,
  });

  @override
  Widget? visitElementAfter(element, TextStyle? preferredStyle) {
    final language = element.attributes['class']?.replaceFirst('language-', '') ?? '';
    final code = element.textContent;

    // Check for Mermaid diagrams
    if (language == 'mermaid') {
      return MermaidDiagram(
        diagramCode: code,
        currentTheme: currentTheme,
      );
    }

    // Syntax highlighted code block
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: currentTheme == 'seez'
            ? SeezTheme.lightBeigeGradient1
            : (currentTheme == 'dark'
                ? AppTheme.darkBackground
                : AppTheme.lighterBackground),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: currentTheme == 'seez'
              ? SeezTheme.mediumBrownBorder
              : (currentTheme == 'dark'
                  ? AppTheme.borderDark
                  : AppTheme.border),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Language label
          if (language.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: currentTheme == 'seez'
                    ? SeezTheme.mediumBrownBorder.withValues(alpha: 0.1)
                    : (currentTheme == 'dark'
                        ? AppTheme.borderDark.withValues(alpha: 0.3)
                        : AppTheme.border.withValues(alpha: 0.1)),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Text(
                language,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: currentTheme == 'seez'
                      ? SeezTheme.subtitleBrown
                      : (currentTheme == 'dark'
                          ? AppTheme.textOnDark.withValues(alpha: 0.7)
                          : AppTheme.textSecondary),
                ),
              ),
            ),

          // Code content with syntax highlighting
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: HighlightView(
              code,
              language: language.isNotEmpty ? language : 'plaintext',
              theme: currentTheme == 'dark'
                  ? monokaiSublimeTheme
                  : githubTheme,
              padding: EdgeInsets.zero,
              textStyle: GoogleFonts.jetBrainsMono(
                fontSize: stylePreferences.codeFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
