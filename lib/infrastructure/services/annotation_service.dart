import 'dart:io';
import 'package:uuid/uuid.dart';
import '../../domain/entities/annotation.dart';
import 'annotation_parser.dart';
import 'app_logger.dart';

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
    required String content,
    String color = 'yellow',
    List<String> tags = const [],
  }) async {
    // If line number not provided, try to find it by searching for anchor text
    int? computedLineNumber = lineNumber;
    if (computedLineNumber == null && anchorText.isNotEmpty) {
      computedLineNumber = await _findLineNumber(filePath, anchorText);
    }

    final annotation = Annotation(
      id: uuid.v4(),
      filePath: filePath,
      anchorText: anchorText,
      lineNumber: computedLineNumber,
      content: content,
      color: color,
      createdAt: DateTime.now(),
      tags: tags,
    );

    AppLogger.info(
      'Adding annotation',
      tag: 'AnnotationService',
      data: 'File: $filePath, Anchor: $anchorText, Line: $computedLineNumber',
    );

    await saveAnnotation(annotation);
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
