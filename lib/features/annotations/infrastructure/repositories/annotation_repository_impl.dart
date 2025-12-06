import '../../domain/entities/annotation.dart';
import '../../domain/repositories/annotation_repository.dart';
import '../services/annotation_service.dart';

/// Implementation of AnnotationRepository using AnnotationService
class AnnotationRepositoryImpl implements AnnotationRepository {
  final AnnotationService _service;

  AnnotationRepositoryImpl({required AnnotationService service})
      : _service = service;

  @override
  Future<List<Annotation>> getAnnotationsForFile(String filePath) {
    return _service.getAnnotationsForFile(filePath);
  }

  @override
  Future<void> saveAnnotation(Annotation annotation) {
    return _service.saveAnnotation(annotation);
  }

  @override
  Future<void> deleteAnnotation(String filePath, String annotationId) {
    return _service.deleteAnnotation(filePath, annotationId);
  }

  @override
  Future<void> updateAnnotation(Annotation annotation) {
    return _service.updateAnnotation(annotation);
  }

  @override
  Future<List<Annotation>> searchAnnotations(String query) {
    return _service.searchAnnotations(query);
  }

  @override
  Future<Map<String, List<Annotation>>> getAllAnnotationsByFile() {
    return _service.getAllAnnotationsByFile();
  }

  @override
  Future<int> getTotalAnnotationCount() {
    return _service.getTotalAnnotationCount();
  }
}
