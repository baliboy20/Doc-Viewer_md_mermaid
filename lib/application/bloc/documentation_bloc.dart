import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/documentation_repository.dart';
import 'documentation_event.dart';
import 'documentation_state.dart';

/// BLoC for managing documentation state and events
class DocumentationBloc extends Bloc<DocumentationEvent, DocumentationState> {
  final DocumentationRepository repository;

  DocumentationBloc({required this.repository}) : super(const DocumentationInitial()) {
    on<LoadFileTreeEvent>(_onLoadFileTree);
    on<SelectFileEvent>(_onSelectFile);
    on<ToggleFolderEvent>(_onToggleFolder);
    on<SearchFilesEvent>(_onSearchFiles);
    on<RefreshFileTreeEvent>(_onRefreshFileTree);
    on<ClearSelectionEvent>(_onClearSelection);
  }

  /// Handles loading the file tree
  Future<void> _onLoadFileTree(
    LoadFileTreeEvent event,
    Emitter<DocumentationState> emit,
  ) async {
    try {
      final fileTree = await repository.loadFileTree();

      emit(DocumentationLoaded(
        fileTree: fileTree,
        expandedFolders: {},
      ));
    } catch (e) {
      emit(DocumentationError(
        message: 'Failed to load file tree',
        error: e,
      ));
    }
  }

  /// Handles selecting a file and loading its content
  Future<void> _onSelectFile(
    SelectFileEvent event,
    Emitter<DocumentationState> emit,
  ) async {
    final currentState = state;

    if (currentState is DocumentationLoaded) {
      // Set loading state
      emit(currentState.copyWith(
        selectedFilePath: event.filePath,
        isLoadingContent: true,
        clearContent: true,
      ));

      try {
        final content = await repository.readFileContent(event.filePath);

        // Emit loaded content
        emit(currentState.copyWith(
          selectedFilePath: event.filePath,
          currentContent: content,
          isLoadingContent: false,
        ));
      } catch (e) {
        emit(DocumentationError(
          message: 'Failed to load file content: ${event.filePath}',
          error: e,
        ));
      }
    }
  }

  /// Handles toggling folder expansion
  Future<void> _onToggleFolder(
    ToggleFolderEvent event,
    Emitter<DocumentationState> emit,
  ) async {
    final currentState = state;

    if (currentState is DocumentationLoaded) {
      emit(currentState.toggleFolder(
        event.folderPath,
        forceExpand: event.forceExpand,
        forceCollapse: event.forceCollapse,
      ));
    }
  }

  /// Handles searching for files
  Future<void> _onSearchFiles(
    SearchFilesEvent event,
    Emitter<DocumentationState> emit,
  ) async {
    final currentState = state;

    if (currentState is DocumentationLoaded) {
      try {
        final results = await repository.searchFiles(event.query);

        emit(currentState.copyWith(
          searchResults: results,
        ));
      } catch (e) {
        emit(DocumentationError(
          message: 'Failed to search files',
          error: e,
        ));
      }
    }
  }

  /// Handles refreshing the file tree
  Future<void> _onRefreshFileTree(
    RefreshFileTreeEvent event,
    Emitter<DocumentationState> emit,
  ) async {
    final currentState = state;

    if (currentState is DocumentationLoaded) {
      try {
        final fileTree = await repository.loadFileTree();

        emit(currentState.copyWith(
          fileTree: fileTree,
          clearSelection: true,
          clearContent: true,
        ));
      } catch (e) {
        emit(DocumentationError(
          message: 'Failed to refresh file tree',
          error: e,
        ));
      }
    }
  }

  /// Handles clearing the current selection
  Future<void> _onClearSelection(
    ClearSelectionEvent event,
    Emitter<DocumentationState> emit,
  ) async {
    final currentState = state;

    if (currentState is DocumentationLoaded) {
      emit(currentState.copyWith(
        clearSelection: true,
        clearContent: true,
      ));
    }
  }
}
