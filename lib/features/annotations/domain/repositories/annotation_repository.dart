import '../entities/annotation.dart';

/// Repository interface for annotation operations
abstract class AnnotationRepository {
  /// Loads annotations for a specific file
  Future<List<Annotation>> getAnnotationsForFile(String filePath);

  /// Saves or updates an annotation
  Future<void> saveAnnotation(Annotation annotation);

  /// Deletes an annotation
  Future<void> deleteAnnotation(String filePath, String annotationId);

  /// Updates an annotation's content
  Future<void> updateAnnotation(Annotation annotation);

  /// Searches all annotations across all files
  Future<List<Annotation>> searchAnnotations(String query);

  /// Gets all annotations grouped by file
  Future<Map<String, List<Annotation>>> getAllAnnotationsByFile();

  /// Gets total count of annotations across all files
  Future<int> getTotalAnnotationCount();
}
