import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import '../../domain/entities/markdown_style_preferences.dart';
import '../../infrastructure/services/app_logger.dart';
import '../theme/seez_theme.dart';
import '../theme/app_theme.dart';
import 'mermaid_diagram.dart';

/// Markdown viewer with custom styling and code highlighting
class MarkdownViewer extends StatefulWidget {
  final String content;
  final MarkdownStylePreferences stylePreferences;
  final String currentTheme;
  final Function(String selectedText, BuildContext context)? onTextSelected;
  final List<dynamic>? annotations; // List of annotations for anchor injection
  final Map<String, GlobalKey>? annotationKeys; // GlobalKeys for scroll targeting

  const MarkdownViewer({
    super.key,
    required this.content,
    required this.stylePreferences,
    required this.currentTheme,
    this.onTextSelected,
    this.annotations,
    this.annotationKeys,
  });

  @override
  State<MarkdownViewer> createState() => _MarkdownViewerState();
}

class _MarkdownViewerState extends State<MarkdownViewer> {
  final TextSelection _textSelection = const TextSelection.collapsed(offset: 0);
  String _selectedText = '';

  Color get _textColor {
    return widget.currentTheme == 'seez'
        ? SeezTheme.darkBrownText
        : (widget.currentTheme == 'dark'
            ? AppTheme.textOnDark
            : AppTheme.textPrimary);
  }

  Color get _accentColor {
    return widget.currentTheme == 'seez'
        ? SeezTheme.primaryBrown
        : AppTheme.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    // Markers are now permanently in the file content, no need to inject dynamically

    return SelectionArea(
      onSelectionChanged: (selectedContent) {
        setState(() {
          _selectedText = selectedContent?.plainText ?? '';
          AppLogger.debug(
            'Text selected: "${_selectedText}"',
            tag: 'MarkdownViewer',
          );
        });
      },
      contextMenuBuilder: (context, selectableRegionState) {
        // Get the default Copy button
        final defaultButtons = selectableRegionState.contextMenuButtonItems;

        return AdaptiveTextSelectionToolbar(
          anchors: selectableRegionState.contextMenuAnchors,
          children: [
            // Copy button (first default button is usually copy)
            if (defaultButtons.isNotEmpty)
              AdaptiveTextSelectionToolbar.getAdaptiveButtons(
                context,
                [defaultButtons.first], // Only include Copy button
              ).first,

            // Add Annotation button
            if (_selectedText.isNotEmpty && widget.onTextSelected != null)
              TextButton(
                onPressed: () {
                  AppLogger.info(
                    'Add Annotation button clicked',
                    tag: 'MarkdownViewer',
                    data: 'Selected text: "$_selectedText"',
                  );
                  ContextMenuController.removeAny();
                  widget.onTextSelected!(_selectedText, context);
                },
                child: const Text('Add Annotation'),
              ),
          ],
        );
      },
      child: MarkdownBody(
        data: widget.content,
        selectable: false, // Disable MarkdownBody's selection, use SelectionArea instead
        styleSheet: _buildMarkdownStyleSheet(context),
        onTapLink: (text, href, title) {
          if (href != null) {
            _launchUrl(href);
          }
        },
        builders: {
          'code': CodeElementBuilder(
            currentTheme: widget.currentTheme,
            stylePreferences: widget.stylePreferences,
          ),
          'html': HtmlCommentBuilder(
            annotationKeys: widget.annotationKeys ?? {},
          ),
        },
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet(BuildContext context) {
    final baseTextStyle = GoogleFonts.inter(
      fontSize: widget.stylePreferences.baseFontSize,
      height: 1.6,
      letterSpacing: 0.2,
      color: _textColor,
    );

    return MarkdownStyleSheet(
      // Headers - Using Old Standard TT for Seez theme
      h1: (widget.currentTheme == 'seez'
              ? GoogleFonts.oldStandardTt()
              : GoogleFonts.inter())
          .copyWith(
        fontSize: widget.stylePreferences.h1FontSize,
        fontWeight: FontWeight.w400,
        color: _textColor,
        height: 1.3,
      ),

      h2: (widget.currentTheme == 'seez'
              ? GoogleFonts.oldStandardTt()
              : GoogleFonts.inter())
          .copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: _accentColor,
        height: 1.3,
      ),

      h3: (widget.currentTheme == 'seez'
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
        color: widget.currentTheme == 'seez'
            ? SeezTheme.mediumBrownBorder
            : _accentColor,
        fontWeight: FontWeight.w600,
        fontSize: widget.stylePreferences.baseFontSize - 1,
      ),

      // Emphasis/Italic
      em: baseTextStyle.copyWith(
        fontStyle: FontStyle.italic,
      ),

      // Code (inline)
      code: GoogleFonts.jetBrainsMono(
        fontSize: widget.stylePreferences.codeFontSize,
        backgroundColor: widget.currentTheme == 'seez'
            ? SeezTheme.lightCreamTile
            : (widget.currentTheme == 'dark'
                ? AppTheme.darkBackground
                : AppTheme.lighterBackground),
        color: widget.currentTheme == 'seez'
            ? SeezTheme.subtitleBrown
            : (widget.currentTheme == 'dark'
                ? AppTheme.textOnDark
                : AppTheme.textPrimary),
      ),

      // Code blocks
      codeblockDecoration: BoxDecoration(
        color: widget.currentTheme == 'seez'
            ? SeezTheme.lightBeigeGradient1
            : (widget.currentTheme == 'dark'
                ? AppTheme.darkBackground
                : AppTheme.lighterBackground),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.currentTheme == 'seez'
              ? SeezTheme.mediumBrownBorder
              : (widget.currentTheme == 'dark'
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
        color: widget.currentTheme == 'seez'
            ? SeezTheme.lightCreamTile
            : (widget.currentTheme == 'dark'
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
        color: widget.currentTheme == 'seez'
            ? SeezTheme.subtitleBlue
            : AppTheme.primaryBlue,
        decoration: TextDecoration.underline,
      ),

      // Horizontal Rules - Adjustable thickness
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: (widget.currentTheme == 'seez'
                    ? SeezTheme.mediumBrownBorder
                    : (widget.currentTheme == 'dark'
                        ? AppTheme.borderDark
                        : AppTheme.divider))
                .withValues(alpha: 0.3),
            width: widget.stylePreferences.hrThickness,
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
        color: widget.currentTheme == 'seez'
            ? SeezTheme.mediumBrownBorder
            : (widget.currentTheme == 'dark'
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

/// Custom builder for HTML elements to attach GlobalKeys to annotation markers
class HtmlCommentBuilder extends MarkdownElementBuilder {
  final Map<String, GlobalKey> annotationKeys;

  HtmlCommentBuilder({
    required this.annotationKeys,
  });

  @override
  Widget? visitElementAfter(element, TextStyle? preferredStyle) {
    // Check if this is an anchor tag with annotation marker href
    if (element.tag == 'a') {
      final href = element.attributes['href'];
      if (href != null && href.startsWith('#annotation-marker-')) {
        final annotationId = href.substring('#annotation-marker-'.length);

        AppLogger.debug(
          'Found annotation marker anchor in HTML',
          tag: 'HtmlCommentBuilder',
          data: 'ID: $annotationId, href: $href',
        );

        // Get or create GlobalKey for this annotation
        final key = annotationKeys[annotationId];

        if (key != null) {
          AppLogger.info(
            'Attaching GlobalKey to annotation marker anchor',
            tag: 'HtmlCommentBuilder',
            data: 'ID: $annotationId',
          );

          // Return an invisible widget with the key attached
          // Using SizedBox instead of Container for better performance
          return SizedBox(
            key: key,
            width: 0,
            height: 0,
          );
        } else {
          AppLogger.warning(
            'No GlobalKey found for annotation',
            tag: 'HtmlCommentBuilder',
            data: 'ID: $annotationId',
          );
        }
      }
    }

    // Return null for other HTML elements (use default rendering)
    return null;
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
