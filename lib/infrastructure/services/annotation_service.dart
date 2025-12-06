import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:doc_viewer_app/features/annotations/domain/entities/annotation.dart';
import 'annotation_parser.dart';
import 'package:doc_viewer_app/core/utils/app_logger.dart';

/// Service for managing annotations on markdown files
class AnnotationService {
  final String docsRootPath;
  final AnnotationParser parser = AnnotationParser();
  final Uuid uuid = const Uuid();

  AnnotationService({required this.docsRootPath});

  /// Loads annotations for a specific file
  Future<List<Annotation>> getAnnotationsForFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return [];
      }

      final content = await file.readAsString();
      final parsed = parser.parse(content, filePath);

      AppLogger.debug(
        'Loaded ${parsed.annotations.length} annotations',
        tag: 'AnnotationService',
        data: filePath,
      );

      // Debug: Print annotation details
      for (var i = 0; i < parsed.annotations.length; i++) {
        final ann = parsed.annotations[i];
        AppLogger.debug(
          'Annotation $i: ID=${ann.id}, Line=${ann.lineNumber}, Anchor="${ann.anchorText}"',
          tag: 'AnnotationService',
        );
      }

      return parsed.annotations;
    } catch (e) {
      AppLogger.error(
        'Failed to load annotations',
        tag: 'AnnotationService',
        error: e,
        data: filePath,
      );
      throw Exception('Failed to load annotations: $e');
    }
  }

  /// Adds a new annotation to a file
  Future<void> addAnnotation({
    required String filePath,
    required String anchorText,
    required int? lineNumber,
    int? elementIndex,
    required String content,
    String color = 'yellow',
    List<String> tags = const [],
  }) async {
    // Make anchor text unique by expanding context if needed
    final uniqueAnchor = await _makeAnchorUnique(filePath, anchorText);

    // If line number not provided, try to find it by searching for unique anchor text
    int? computedLineNumber = lineNumber;
    if (computedLineNumber == null && uniqueAnchor.isNotEmpty) {
      computedLineNumber = await _findLineNumber(filePath, uniqueAnchor);
    }

    final annotation = Annotation(
      id: uuid.v4(),
      filePath: filePath,
      anchorText: uniqueAnchor,
      lineNumber: computedLineNumber,
      elementIndex: elementIndex,
      content: content,
      color: color,
      createdAt: DateTime.now(),
      tags: tags,
    );

    AppLogger.info(
      'Adding annotation',
      tag: 'AnnotationService',
      data: 'File: $filePath, Original: "$anchorText", Unique: "$uniqueAnchor", Line: $computedLineNumber, Element: $elementIndex',
    );

    await saveAnnotation(annotation);
  }

  /// Makes anchor text unique by iteratively expanding context
  /// Now uses all occurrences and picks the middle one as most likely intended
  Future<String> _makeAnchorUnique(String filePath, String selectedText) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        AppLogger.warning(
          'File does not exist for anchor uniqueness check',
          tag: 'AnnotationService',
          data: filePath,
        );
        return selectedText;
      }

      final fileContent = await file.readAsString();
      final parsed = parser.parse(fileContent, filePath);
      final content = parsed.content;

      // Find all occurrences of the selected text
      final occurrences = _findAllOccurrences(content, selectedText);

      AppLogger.debug(
        'Checking anchor uniqueness',
        tag: 'AnnotationService',
        data: 'Text: "$selectedText", Occurrences: ${occurrences.length}',
      );

      if (occurrences.length <= 1) {
        // Already unique!
        return selectedText;
      }

      // Multiple occurrences - need to expand each one and find which becomes unique fastest
      // We'll try expanding around each occurrence and use the one that becomes unique first
      String? uniqueAnchor;

      for (int occIndex = 0; occIndex < occurrences.length; occIndex++) {
        final selectionStart = occurrences[occIndex];
        final selectionEnd = selectionStart + selectedText.length;

        // Extract words before and after THIS occurrence
        final beforeText = content.substring(0, selectionStart);
        final afterText = content.substring(selectionEnd);

        final wordsBefore = _extractWords(beforeText, reverse: true);
        final wordsAfter = _extractWords(afterText, reverse: false);

        // Try to make THIS occurrence unique
        String expandedAnchor = selectedText;
        int beforeIndex = 0;
        int afterIndex = 0;
        const maxExpansions = 15; // Increased from 10

        for (int i = 0; i < maxExpansions * 2; i++) {
          // Add more words at once for faster uniqueness
          int wordsToAdd = (i < 4) ? 1 : 2; // Add 2 words at a time after first few iterations

          if (i % 2 == 0 && beforeIndex < wordsBefore.length) {
            // Add word(s) before
            for (int w = 0; w < wordsToAdd && beforeIndex < wordsBefore.length; w++) {
              expandedAnchor = '${wordsBefore[beforeIndex]} $expandedAnchor';
              beforeIndex++;
            }
          } else if (afterIndex < wordsAfter.length) {
            // Add word(s) after
            for (int w = 0; w < wordsToAdd && afterIndex < wordsAfter.length; w++) {
              expandedAnchor = '$expandedAnchor ${wordsAfter[afterIndex]}';
              afterIndex++;
            }
          }

          // Check if now unique
          final newOccurrences = _countOccurrences(content, expandedAnchor);

          if (newOccurrences == 1) {
            uniqueAnchor = expandedAnchor;
            AppLogger.success(
              'Made anchor unique for occurrence $occIndex',
              tag: 'AnnotationService',
              data: 'Original: "$selectedText", Unique: "$expandedAnchor"',
            );
            break; // Found unique anchor for this occurrence
          }

          // Stop if we've run out of words
          if (beforeIndex >= wordsBefore.length && afterIndex >= wordsAfter.length) {
            break;
          }
        }

        if (uniqueAnchor != null) {
          break; // Successfully made unique
        }
      }

      if (uniqueAnchor != null) {
        return uniqueAnchor;
      }

      // If still not unique, return expanded version of first occurrence
      AppLogger.warning(
        'Could not make anchor unique after trying all occurrences',
        tag: 'AnnotationService',
        data: 'Text: "$selectedText", Occurrences: ${occurrences.length}',
      );

      return selectedText;

    } catch (e) {
      AppLogger.error(
        'Error making anchor unique',
        tag: 'AnnotationService',
        error: e,
        data: 'Selected: "$selectedText"',
      );
      return selectedText;
    }
  }

  /// Finds all occurrences of text and returns their positions
  List<int> _findAllOccurrences(String content, String searchText) {
    final contentLower = content.toLowerCase();
    final searchLower = searchText.toLowerCase().trim();
    final positions = <int>[];

    int startIndex = 0;
    while (true) {
      final index = contentLower.indexOf(searchLower, startIndex);
      if (index == -1) break;
      positions.add(index);
      startIndex = index + searchLower.length;
    }

    return positions;
  }

  /// Counts case-insensitive occurrences of text in content
  int _countOccurrences(String content, String searchText) {
    return _findAllOccurrences(content, searchText).length;
  }

  /// Extracts words from text (in order or reverse)
  List<String> _extractWords(String text, {required bool reverse}) {
    // Remove markdown syntax and split into words
    final cleaned = text
        .replaceAll(RegExp(r'[#*_\[\]\(\)]'), ' ') // Remove markdown chars
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();

    if (cleaned.isEmpty) return [];

    final words = cleaned.split(' ').where((w) => w.isNotEmpty).toList();

    return reverse ? words.reversed.toList() : words;
  }

  /// Finds the line number where the anchor text appears in the file
  Future<int?> _findLineNumber(String filePath, String anchorText) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        AppLogger.warning(
          'File does not exist for line number search',
          tag: 'AnnotationService',
          data: filePath,
        );
        return 1; // Default to line 1
      }

      final fileContent = await file.readAsString();
      final parsed = parser.parse(fileContent, filePath);
      final lines = parsed.content.split('\n');

      // Search for the anchor text in the content (case-insensitive)
      final anchorLower = anchorText.toLowerCase().trim();

      AppLogger.debug(
        'Searching for anchor in ${lines.length} lines',
        tag: 'AnnotationService',
        data: 'Anchor: "$anchorText"',
      );

      for (var i = 0; i < lines.length; i++) {
        if (lines[i].toLowerCase().contains(anchorLower)) {
          AppLogger.debug(
            'Found anchor at line ${i + 1}',
            tag: 'AnnotationService',
          );
          return i + 1; // Return 1-indexed line number
        }
      }

      AppLogger.warning(
        'Anchor text not found in document, defaulting to line 1',
        tag: 'AnnotationService',
        data: 'Anchor: "$anchorText"',
      );

      // Default to line 1 if not found instead of null
      return 1;
    } catch (e) {
      AppLogger.warning(
        'Failed to find line number for anchor',
        tag: 'AnnotationService',
        data: 'Anchor: $anchorText, Error: $e',
      );
      return 1; // Default to line 1
    }
  }

  /// Saves or updates an annotation
  Future<void> saveAnnotation(Annotation annotation) async {
    try {
      final file = File(annotation.filePath);

      if (!file.existsSync()) {
        throw Exception('File does not exist: ${annotation.filePath}');
      }

      final fileContent = await file.readAsString();
      final parsed = parser.parse(fileContent, annotation.filePath);

      // Check if annotation exists (update) or is new (add)
      final existingIndex = parsed.annotations.indexWhere(
        (a) => a.id == annotation.id,
      );

      List<Annotation> updatedAnnotations;

      if (existingIndex >= 0) {
        // Update existing
        updatedAnnotations = List.from(parsed.annotations);
        updatedAnnotations[existingIndex] = annotation.copyWith(
          updatedAt: DateTime.now(),
        );

        AppLogger.info(
          'Updated annotation',
          tag: 'AnnotationService',
          data: 'ID: ${annotation.id}',
        );
      } else {
        // Add new
        updatedAnnotations = [...parsed.annotations, annotation];

        AppLogger.info(
          'Added new annotation',
          tag: 'AnnotationService',
          data: 'ID: ${annotation.id}',
        );
      }

      // Serialize and save
      final newContent = parser.serialize(parsed.content, updatedAnnotations);
      await file.writeAsString(newContent);

      AppLogger.success(
        'Saved annotation to file',
        tag: 'AnnotationService',
        data: annotation.filePath,
      );
    } catch (e) {
      AppLogger.error(
        'Failed to save annotation',
        tag: 'AnnotationService',
        error: e,
        data: annotation.filePath,
      );
      throw Exception('Failed to save annotation: $e');
    }
  }

  /// Deletes an annotation
  Future<void> deleteAnnotation(String filePath, String annotationId) async {
    try {
      final file = File(filePath);

      if (!file.existsSync()) {
        throw Exception('File does not exist: $filePath');
      }

      final fileContent = await file.readAsString();
      final parsed = parser.parse(fileContent, filePath);

      // Remove annotation
      final updatedAnnotations = parsed.annotations
          .where((a) => a.id != annotationId)
          .toList();

      // Serialize and save
      final newContent = parser.serialize(parsed.content, updatedAnnotations);
      await file.writeAsString(newContent);

      AppLogger.success(
        'Deleted annotation',
        tag: 'AnnotationService',
        data: 'ID: $annotationId',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to delete annotation',
        tag: 'AnnotationService',
        error: e,
        data: 'File: $filePath, ID: $annotationId',
      );
      throw Exception('Failed to delete annotation: $e');
    }
  }

  /// Updates an annotation's content
  Future<void> updateAnnotation(Annotation annotation) async {
    await saveAnnotation(annotation.copyWith(
      updatedAt: DateTime.now(),
    ));
  }

  /// Searches all annotations across all files
  Future<List<Annotation>> searchAnnotations(String query) async {
    final allAnnotations = <Annotation>[];

    AppLogger.info(
      'Searching annotations',
      tag: 'AnnotationService',
      data: 'Query: $query',
    );

    // Recursively search all .md files
    await _searchDirectory(Directory(docsRootPath), query, allAnnotations);

    AppLogger.success(
      'Search complete',
      tag: 'AnnotationService',
      data: 'Found ${allAnnotations.length} results',
    );

    return allAnnotations;
  }

  Future<void> _searchDirectory(
    Directory dir,
    String query,
    List<Annotation> results,
  ) async {
    try {
      final entities = dir.listSync();

      for (final entity in entities) {
        // Skip hidden directories
        final name = entity.path.split('/').last;
        if (name.startsWith('.')) {
          continue;
        }

        if (entity is Directory) {
          await _searchDirectory(entity, query, results);
        } else if (entity is File && entity.path.endsWith('.md')) {
          final annotations = await getAnnotationsForFile(entity.path);
          final matches = annotations.where((a) =>
              a.content.toLowerCase().contains(query.toLowerCase()) ||
              a.anchorText.toLowerCase().contains(query.toLowerCase()) ||
              a.tags.any((t) => t.toLowerCase().contains(query.toLowerCase())));

          results.addAll(matches);
        }
      }
    } catch (e) {
      // Skip directories we can't read
      AppLogger.warning(
        'Cannot search directory',
        tag: 'AnnotationService',
        data: '${dir.path}: $e',
      );
    }
  }

  /// Gets all annotations grouped by file
  Future<Map<String, List<Annotation>>> getAllAnnotationsByFile() async {
    final result = <String, List<Annotation>>{};

    AppLogger.info(
      'Loading all annotations',
      tag: 'AnnotationService',
    );

    await _collectAllAnnotations(Directory(docsRootPath), result);

    AppLogger.success(
      'Loaded all annotations',
      tag: 'AnnotationService',
      data: '${result.length} files with annotations',
    );

    return result;
  }

  Future<void> _collectAllAnnotations(
    Directory dir,
    Map<String, List<Annotation>> result,
  ) async {
    try {
      final entities = dir.listSync();

      for (final entity in entities) {
        // Skip hidden directories
        final name = entity.path.split('/').last;
        if (name.startsWith('.')) {
          continue;
        }

        if (entity is Directory) {
          await _collectAllAnnotations(entity, result);
        } else if (entity is File && entity.path.endsWith('.md')) {
          final annotations = await getAnnotationsForFile(entity.path);
          if (annotations.isNotEmpty) {
            result[entity.path] = annotations;
          }
        }
      }
    } catch (e) {
      // Skip directories we can't read
      AppLogger.warning(
        'Cannot access directory',
        tag: 'AnnotationService',
        data: '${dir.path}: $e',
      );
    }
  }

  /// Gets total count of annotations across all files
  Future<int> getTotalAnnotationCount() async {
    final allAnnotations = await getAllAnnotationsByFile();
    return allAnnotations.values.fold<int>(0, (sum, list) => sum + list.length);
  }

  /// Gets annotations statistics
  Future<AnnotationStats> getStats() async {
    final allAnnotations = await getAllAnnotationsByFile();

    int totalCount = 0;
    final colorCounts = <String, int>{};
    final tagCounts = <String, int>{};

    for (final annotations in allAnnotations.values) {
      for (final annotation in annotations) {
        totalCount++;

        // Count colors
        colorCounts[annotation.color] =
            (colorCounts[annotation.color] ?? 0) + 1;

        // Count tags
        for (final tag in annotation.tags) {
          tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
      }
    }

    return AnnotationStats(
      totalCount: totalCount,
      filesWithAnnotations: allAnnotations.length,
      colorCounts: colorCounts,
      tagCounts: tagCounts,
    );
  }
}

/// Statistics about annotations
class AnnotationStats {
  final int totalCount;
  final int filesWithAnnotations;
  final Map<String, int> colorCounts;
  final Map<String, int> tagCounts;

  AnnotationStats({
    required this.totalCount,
    required this.filesWithAnnotations,
    required this.colorCounts,
    required this.tagCounts,
  });
}
