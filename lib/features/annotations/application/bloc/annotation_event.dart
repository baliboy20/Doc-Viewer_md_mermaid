import 'package:equatable/equatable.dart';
import '../../domain/entities/annotation.dart';

/// Base class for annotation events
abstract class AnnotationEvent extends Equatable {
  const AnnotationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load annotations for a specific file
class LoadAnnotationsEvent extends AnnotationEvent {
  final String filePath;

  const LoadAnnotationsEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// Event to add a new annotation
class AddAnnotationEvent extends AnnotationEvent {
  final String filePath;
  final String anchorText;
  final int? lineNumber;
  final String content;
  final String color;
  final List<String> tags;

  const AddAnnotationEvent({
    required this.filePath,
    required this.anchorText,
    required this.lineNumber,
    required this.content,
    this.color = 'yellow',
    this.tags = const [],
  });

  @override
  List<Object?> get props => [filePath, anchorText, lineNumber, content, color, tags];
}

/// Event to update an existing annotation
class UpdateAnnotationEvent extends AnnotationEvent {
  final Annotation annotation;

  const UpdateAnnotationEvent(this.annotation);

  @override
  List<Object?> get props => [annotation];
}

/// Event to delete an annotation
class DeleteAnnotationEvent extends AnnotationEvent {
  final String filePath;
  final String annotationId;

  const DeleteAnnotationEvent(this.filePath, this.annotationId);

  @override
  List<Object?> get props => [filePath, annotationId];
}

/// Event to search annotations
class SearchAnnotationsEvent extends AnnotationEvent {
  final String query;

  const SearchAnnotationsEvent(this.query);

  @override
  List<Object?> get props => [query];
}
