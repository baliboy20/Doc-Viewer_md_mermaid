import 'package:equatable/equatable.dart';
import 'package:doc_viewer_app/features/documentation/domain/entities/file_node.dart';
import '../../domain/entities/annotation.dart';

/// Base class for all documentation states
abstract class DocumentationState extends Equatable {
  const DocumentationState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class DocumentationInitial extends DocumentationState {
  const DocumentationInitial();
}

/// State when documentation is successfully loaded
class DocumentationLoaded extends DocumentationState {
  final List<FileNode> fileTree;
  final Set<String> expandedFolders;
  final String? selectedFilePath;
  final String? currentContent;
  final bool isLoadingContent;
  final List<FileNode>? searchResults;

  // Annotation-related fields
  final List<Annotation> annotations;
  final String? highlightedAnnotationId;
  final bool isLoadingAnnotations;

  const DocumentationLoaded({
    required this.fileTree,
    this.expandedFolders = const {},
    this.selectedFilePath,
    this.currentContent,
    this.isLoadingContent = false,
    this.searchResults,
    this.annotations = const [],
    this.highlightedAnnotationId,
    this.isLoadingAnnotations = false,
  });

  /// Creates a copy with updated fields
  DocumentationLoaded copyWith({
    List<FileNode>? fileTree,
    Set<String>? expandedFolders,
    String? selectedFilePath,
    String? currentContent,
    bool? isLoadingContent,
    List<FileNode>? searchResults,
    List<Annotation>? annotations,
    String? highlightedAnnotationId,
    bool? isLoadingAnnotations,
    bool clearSelection = false,
    bool clearContent = false,
    bool clearSearch = false,
    bool clearHighlight = false,
  }) {
    return DocumentationLoaded(
      fileTree: fileTree ?? this.fileTree,
      expandedFolders: expandedFolders ?? this.expandedFolders,
      selectedFilePath: clearSelection ? null : (selectedFilePath ?? this.selectedFilePath),
      currentContent: clearContent ? null : (currentContent ?? this.currentContent),
      isLoadingContent: isLoadingContent ?? this.isLoadingContent,
      searchResults: clearSearch ? null : (searchResults ?? this.searchResults),
      annotations: annotations ?? this.annotations,
      highlightedAnnotationId: clearHighlight
          ? null
          : (highlightedAnnotationId ?? this.highlightedAnnotationId),
      isLoadingAnnotations: isLoadingAnnotations ?? this.isLoadingAnnotations,
    );
  }

  /// Toggles the expansion state of a folder
  DocumentationLoaded toggleFolder(String folderPath, {bool? forceExpand, bool? forceCollapse}) {
    final newExpandedFolders = Set<String>.from(expandedFolders);

    if (forceExpand == true) {
      newExpandedFolders.add(folderPath);
    } else if (forceCollapse == true) {
      newExpandedFolders.remove(folderPath);
    } else {
      if (newExpandedFolders.contains(folderPath)) {
        newExpandedFolders.remove(folderPath);
      } else {
        newExpandedFolders.add(folderPath);
      }
    }

    return copyWith(expandedFolders: newExpandedFolders);
  }

  @override
  List<Object?> get props => [
        fileTree,
        expandedFolders,
        selectedFilePath,
        currentContent,
        isLoadingContent,
        searchResults,
        annotations,
        highlightedAnnotationId,
        isLoadingAnnotations,
      ];
}

/// State when an error occurs
class DocumentationError extends DocumentationState {
  final String message;
  final Object? error;

  const DocumentationError({
    required this.message,
    this.error,
  });

  @override
  List<Object?> get props => [message, error];
}
