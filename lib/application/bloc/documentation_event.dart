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
