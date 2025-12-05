import 'package:equatable/equatable.dart';

/// Base class for all documentation events
abstract class DocumentationEvent extends Equatable {
  const DocumentationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the file tree from the documentation directory
class LoadFileTreeEvent extends DocumentationEvent {
  const LoadFileTreeEvent();
}

/// Event to select and load a specific file
class SelectFileEvent extends DocumentationEvent {
  final String filePath;

  const SelectFileEvent({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

/// Event to toggle folder expansion state
class ToggleFolderEvent extends DocumentationEvent {
  final String folderPath;
  final bool? forceExpand;
  final bool? forceCollapse;

  const ToggleFolderEvent({
    required this.folderPath,
    this.forceExpand,
    this.forceCollapse,
  });

  @override
  List<Object?> get props => [folderPath, forceExpand, forceCollapse];
}

/// Event to search for files matching a query
class SearchFilesEvent extends DocumentationEvent {
  final String query;

  const SearchFilesEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Event to refresh the file tree
class RefreshFileTreeEvent extends DocumentationEvent {
  const RefreshFileTreeEvent();
}

/// Event to clear the current selection
class ClearSelectionEvent extends DocumentationEvent {
  const ClearSelectionEvent();
}

// ============================================================================
// Annotation Events
// ============================================================================

/// Event to load annotations for the current file
class LoadAnnotationsEvent extends DocumentationEvent {
  final String filePath;

  const LoadAnnotationsEvent({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

/// Event to add a new annotation
class AddAnnotationEvent extends DocumentationEvent {
  final String filePath;
  final String anchorText;
  final int? lineNumber;
  final String content;
  final String color;
  final List<String> tags;

  const AddAnnotationEvent({
    required this.filePath,
    required this.anchorText,
    this.lineNumber,
    required this.content,
    this.color = 'yellow',
    this.tags = const [],
  });

  @override
  List<Object?> get props => [filePath, anchorText, lineNumber, content, color, tags];
}

/// Event to update an existing annotation
class UpdateAnnotationEvent extends DocumentationEvent {
  final String filePath;
  final String annotationId;
  final String? anchorText;
  final int? lineNumber;
  final String? content;
  final String? color;
  final List<String>? tags;

  const UpdateAnnotationEvent({
    required this.filePath,
    required this.annotationId,
    this.anchorText,
    this.lineNumber,
    this.content,
    this.color,
    this.tags,
  });

  @override
  List<Object?> get props => [filePath, annotationId, anchorText, lineNumber, content, color, tags];
}

/// Event to delete an annotation
class DeleteAnnotationEvent extends DocumentationEvent {
  final String filePath;
  final String annotationId;

  const DeleteAnnotationEvent({
    required this.filePath,
    required this.annotationId,
  });

  @override
  List<Object?> get props => [filePath, annotationId];
}

/// Event to search annotations
class SearchAnnotationsEvent extends DocumentationEvent {
  final String query;

  const SearchAnnotationsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Event to highlight a specific annotation
class HighlightAnnotationEvent extends DocumentationEvent {
  final String annotationId;

  const HighlightAnnotationEvent({required this.annotationId});

  @override
  List<Object?> get props => [annotationId];
}

/// Event to clear annotation highlight
class ClearAnnotationHighlightEvent extends DocumentationEvent {
  const ClearAnnotationHighlightEvent();
}
