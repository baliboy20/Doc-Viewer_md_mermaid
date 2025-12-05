import '../../domain/entities/annotation.dart';

/// Parses and serializes annotations from/to markdown files
class AnnotationParser {
  static const String sectionDelimiter =
      '---\n\n<!-- ANNOTATIONS_SECTION_START -->\n\n## 📌 Annotations\n';
  static const String sectionEnd = '<!-- ANNOTATIONS_SECTION_END -->';
  static const String noteSeparator = '---\n';

  /// Parses a markdown file and extracts content + annotations
  ParsedDocument parse(String fileContent, String filePath) {
    // Check if annotations section exists
    final startIndex = fileContent.indexOf(sectionDelimiter);

    // ignore: avoid_print
    print('DEBUG: Parsing file: $filePath');
    // ignore: avoid_print
    print('DEBUG: Section delimiter index: $startIndex');
    // ignore: avoid_print
    print('DEBUG: File length: ${fileContent.length}');

    if (startIndex == -1) {
      // No annotations section
      // ignore: avoid_print
      print('DEBUG: No annotations section found');
      return ParsedDocument(
        content: fileContent,
        annotations: [],
      );
    }

    // Extract content (everything before annotations section)
    final content = fileContent.substring(0, startIndex).trim();

    // Extract annotations section
    final endMarker = fileContent.indexOf(sectionEnd);
    final annotationsSection = fileContent.substring(
      startIndex + sectionDelimiter.length,
      endMarker != -1 ? endMarker : fileContent.length,
    );

    // ignore: avoid_print
    print('DEBUG: Annotations section length: ${annotationsSection.length}');
    // ignore: avoid_print
    print('DEBUG: Annotations section preview: ${annotationsSection.substring(0, annotationsSection.length > 200 ? 200 : annotationsSection.length)}');

    // Parse individual annotations
    final annotations = _parseAnnotationsSection(annotationsSection, filePath);

    // ignore: avoid_print
    print('DEBUG: Parsed ${annotations.length} annotations');

    return ParsedDocument(
      content: content,
      annotations: annotations,
    );
  }

  List<Annotation> _parseAnnotationsSection(String section, String filePath) {
    final annotations = <Annotation>[];

    // Split by note separator
    final noteSections = section.split(noteSeparator);

    for (final noteSection in noteSections) {
      final trimmed = noteSection.trim();
      if (trimmed.isEmpty || !trimmed.startsWith('###')) {
        continue;
      }

      try {
        final annotation = _parseAnnotation(trimmed, filePath);
        if (annotation != null) {
          annotations.add(annotation);
        }
      } catch (e) {
        // Log warning but continue parsing other annotations
        // ignore: avoid_print
        print('Warning: Failed to parse annotation: $e');
      }
    }

    return annotations;
  }

  Annotation? _parseAnnotation(String noteSection, String filePath) {
    final lines = noteSection.split('\n');

    String? id;
    String? anchorText;
    int? lineNumber;
    String? color;
    DateTime? createdAt;
    DateTime? updatedAt;
    final tags = <String>[];
    final contentLines = <String>[];

    bool inContent = false;
    int contentStartIndex = -1;

    // First pass: find where content starts (first empty line after metadata)
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (i == 0) {
        // Skip heading line "### 📝 Note N"
        continue;
      }

      if (inContent) {
        // Already in content section, keep going
        continue;
      }

      // Check if this line is metadata
      if (line.startsWith('**Anchor:**')) {
        anchorText = _extractValue(line).replaceAll('"', '');
      } else if (line.startsWith('**Line:**')) {
        final lineValue = _extractValue(line);
        if (lineValue.isNotEmpty && lineValue != 'N/A') {
          lineNumber = int.tryParse(lineValue);
        }
      } else if (line.startsWith('**ID:**')) {
        id = _extractValue(line);
      } else if (line.startsWith('**Created:**')) {
        createdAt = DateTime.tryParse(_extractValue(line));
      } else if (line.startsWith('**Updated:**')) {
        updatedAt = DateTime.tryParse(_extractValue(line));
      } else if (line.startsWith('**Color:**')) {
        color = _extractValue(line);
      } else if (line.startsWith('**Tags:**')) {
        final tagString = _extractValue(line);
        tags.addAll(
          tagString
              .split(' ')
              .where((t) => t.startsWith('#'))
              .map((t) => t.substring(1))
              .toList(),
        );
      } else if (line.trim().isEmpty && anchorText != null) {
        // First empty line after we've seen metadata = start of content
        inContent = true;
        contentStartIndex = i + 1;
        break;
      }
    }

    // Second pass: collect all content lines
    if (contentStartIndex > 0 && contentStartIndex < lines.length) {
      for (var i = contentStartIndex; i < lines.length; i++) {
        contentLines.add(lines[i]);
      }
    }

    // Validate required fields
    if (id == null || anchorText == null || createdAt == null) {
      return null;
    }

    return Annotation(
      id: id,
      filePath: filePath,
      anchorText: anchorText,
      lineNumber: lineNumber,
      content: contentLines.join('\n').trim(),
      color: color ?? 'yellow',
      createdAt: createdAt,
      updatedAt: updatedAt,
      tags: tags,
    );
  }

  String _extractValue(String line) {
    // Extract value after "**Key:** value"
    // Format is: **Key:** value where the colon is INSIDE the bold markers
    final pattern = RegExp(r'\*\*(.+?):\*\*\s*(.*)');
    final match = pattern.firstMatch(line);
    if (match != null && match.groupCount >= 2) {
      // Group 1 is the key, Group 2 is the value
      return match.group(2)?.trim() ?? '';
    }

    // Fallback to simple colon split if pattern doesn't match
    final colonIndex = line.indexOf(':');
    if (colonIndex == -1) return '';
    return line.substring(colonIndex + 1).trim();
  }

  /// Serializes content and annotations back to markdown format
  String serialize(String content, List<Annotation> annotations) {
    final buffer = StringBuffer();

    // Write main content
    buffer.write(content.trimRight());
    buffer.write('\n\n');

    // If no annotations, return just content
    if (annotations.isEmpty) {
      return buffer.toString();
    }

    // Write annotations section
    buffer.write(sectionDelimiter);

    // Sort annotations by creation date
    final sorted = List<Annotation>.from(annotations)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    for (var i = 0; i < sorted.length; i++) {
      final annotation = sorted[i];

      buffer.write('\n### 📝 Note ${i + 1}\n');
      buffer.write('**Anchor:** "${annotation.anchorText}"\n');
      buffer.write('**Line:** ${annotation.lineNumber ?? "N/A"}\n');
      buffer.write('**ID:** ${annotation.id}\n');
      buffer.write('**Created:** ${_formatDateTime(annotation.createdAt)}\n');

      if (annotation.updatedAt != null) {
        buffer.write('**Updated:** ${_formatDateTime(annotation.updatedAt!)}\n');
      }

      buffer.write('**Color:** ${annotation.color}\n');

      if (annotation.tags.isNotEmpty) {
        buffer.write('**Tags:** ${annotation.tags.map((t) => '#$t').join(' ')}\n');
      }

      buffer.write('\n');
      buffer.write(annotation.content);
      buffer.write('\n\n');
      buffer.write(noteSeparator);
    }

    buffer.write('\n');
    buffer.write(sectionEnd);
    buffer.write('\n');

    return buffer.toString();
  }

  String _formatDateTime(DateTime dt) {
    return dt.toIso8601String().replaceAll('T', ' ').substring(0, 19);
  }
}

/// Result of parsing a markdown file
class ParsedDocument {
  final String content;
  final List<Annotation> annotations;

  const ParsedDocument({
    required this.content,
    required this.annotations,
  });
}
