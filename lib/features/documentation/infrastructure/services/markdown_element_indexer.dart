import 'package:markdown/markdown.dart' as md;
import 'package:doc_viewer_app/core/utils/app_logger.dart';

/// Pre-processes markdown to inject invisible element index markers
class MarkdownElementIndexer {
  /// Processes markdown content and injects element index markers
  /// Returns modified markdown with [](#ln-X) markers before each block element
  String injectElementMarkers(String markdownContent) {
    try {
      // Parse markdown to AST
      final document = md.Document(
        encodeHtml: false,
        extensionSet: md.ExtensionSet.gitHubFlavored,
      );

      final lines = markdownContent.split('\n');
      final nodes = document.parseLines(lines);

      AppLogger.debug(
        'Parsed markdown into elements',
        tag: 'MarkdownElementIndexer',
        data: 'Total nodes: ${nodes.length}',
      );

      // Build result with markers injected
      final result = StringBuffer();
      int elementIndex = 0;

      for (final node in nodes) {
        // Inject marker before this element
        result.writeln('[](#ln-$elementIndex)');

        // Add the original markdown for this element
        result.writeln(_nodeToMarkdown(node, lines));

        elementIndex++;
      }

      AppLogger.info(
        'Injected element markers',
        tag: 'MarkdownElementIndexer',
        data: 'Total elements: $elementIndex',
      );

      return result.toString();

    } catch (e) {
      AppLogger.error(
        'Failed to inject element markers',
        tag: 'MarkdownElementIndexer',
        error: e,
      );
      // Return original content on error
      return markdownContent;
    }
  }

  /// Converts a parsed node back to markdown text
  String _nodeToMarkdown(md.Node node, List<String> originalLines) {
    // Get the source position of this node
    if (node is md.Element) {
      // Try to reconstruct from children
      final buffer = StringBuffer();

      if (node.children != null) {
        for (final child in node.children!) {
          if (child is md.Text) {
            buffer.write(child.text);
          } else if (child is md.Element) {
            buffer.write(_nodeToMarkdown(child, originalLines));
          }
        }
      }

      // Wrap in appropriate markdown syntax based on tag
      return _wrapInMarkdown(node.tag, buffer.toString());
    } else if (node is md.Text) {
      return node.text;
    }

    return '';
  }

  /// Wraps text in markdown syntax based on element type
  String _wrapInMarkdown(String tag, String content) {
    switch (tag) {
      case 'h1':
        return '# $content';
      case 'h2':
        return '## $content';
      case 'h3':
        return '### $content';
      case 'h4':
        return '#### $content';
      case 'h5':
        return '##### $content';
      case 'h6':
        return '###### $content';
      case 'p':
        return content;
      case 'ul':
      case 'ol':
      case 'li':
        return content;
      case 'blockquote':
        return '> $content';
      case 'code':
        return '`$content`';
      case 'pre':
        return '```\n$content\n```';
      default:
        return content;
    }
  }

  /// Alternative simpler approach: Line-by-line injection
  /// Injects markers based on simple line pattern matching
  /// This version properly handles paragraph boundaries and code blocks
  String injectElementMarkersSimple(String markdownContent) {
    final lines = markdownContent.split('\n');
    final result = StringBuffer();
    int elementIndex = 0;
    bool inParagraph = false;
    bool inCodeBlock = false;
    String? codeBlockDelimiter;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      // Skip existing annotation markers - preserve them as-is
      if (trimmed.startsWith('[📌](#annotation-marker-') ||
          trimmed.startsWith('[](#annotation-marker-')) {
        result.writeln(line);
        inParagraph = false; // Annotation marker breaks paragraph flow
        continue;
      }

      // Skip existing element markers - don't duplicate
      if (trimmed.startsWith('[](#ln-')) {
        result.writeln(line);
        continue;
      }

      // Handle code blocks
      if (trimmed.startsWith('```') || trimmed.startsWith('~~~')) {
        final delimiter = trimmed.substring(0, 3);
        if (!inCodeBlock) {
          // Starting code block
          result.writeln('[](#ln-$elementIndex)');
          elementIndex++;
          inCodeBlock = true;
          codeBlockDelimiter = delimiter;
          inParagraph = false;
        } else if (delimiter == codeBlockDelimiter) {
          // Ending code block
          inCodeBlock = false;
          codeBlockDelimiter = null;
        }
        result.writeln(line);
        continue;
      }

      // Don't inject markers inside code blocks
      if (inCodeBlock) {
        result.writeln(line);
        continue;
      }

      // Blank line ends paragraph
      if (trimmed.isEmpty) {
        inParagraph = false;
        result.writeln(line);
        continue;
      }

      // Check for distinct block elements
      bool isHeading = trimmed.startsWith('#') && trimmed.contains(' ');
      bool isList = trimmed.startsWith('- ') ||
                    trimmed.startsWith('* ') ||
                    trimmed.startsWith('+ ') ||
                    RegExp(r'^\d+\.\s').hasMatch(trimmed);
      bool isBlockquote = trimmed.startsWith('> ');
      bool isHR = (trimmed == '---' || trimmed == '***' || trimmed == '___' ||
                   trimmed.startsWith('---') || trimmed.startsWith('***'));
      bool isTable = trimmed.startsWith('|') && trimmed.endsWith('|');

      if (isHeading || isList || isBlockquote || isHR || isTable) {
        // These are distinct block elements - always inject marker
        result.writeln('[](#ln-$elementIndex)');
        elementIndex++;
        inParagraph = false;
        result.writeln(line);
      } else {
        // Regular text line - part of a paragraph
        if (!inParagraph) {
          // Starting a new paragraph
          result.writeln('[](#ln-$elementIndex)');
          elementIndex++;
          inParagraph = true;
        }
        result.writeln(line);
      }
    }

    AppLogger.info(
      'Injected element markers (simple)',
      tag: 'MarkdownElementIndexer',
      data: 'Total elements: $elementIndex',
    );

    return result.toString();
  }
}
