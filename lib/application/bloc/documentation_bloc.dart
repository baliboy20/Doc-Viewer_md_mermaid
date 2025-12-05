import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/annotation.dart';
import '../../domain/repositories/documentation_repository.dart';
import '../../infrastructure/services/annotation_service.dart';
import '../../infrastructure/services/app_logger.dart';
import 'documentation_event.dart';
import 'documentation_state.dart';

/// BLoC for managing documentation state and events
class DocumentationBloc extends Bloc<DocumentationEvent, DocumentationState> {
  final DocumentationRepository repository;
  final AnnotationService? annotationService;

  DocumentationBloc({
    required this.repository,
    this.annotationService,
  }) : super(const DocumentationInitial()) {
    on<LoadFileTreeEvent>(_onLoadFileTree);
    on<SelectFileEvent>(_onSelectFile);
    on<ToggleFolderEvent>(_onToggleFolder);
    on<SearchFilesEvent>(_onSearchFiles);
    on<RefreshFileTreeEvent>(_onRefreshFileTree);
    on<ClearSelectionEvent>(_onClearSelection);

    // Annotation event handlers
    on<LoadAnnotationsEvent>(_onLoadAnnotations);
    on<AddAnnotationEvent>(_onAddAnnotation);
    on<UpdateAnnotationEvent>(_onUpdateAnnotation);
    on<DeleteAnnotationEvent>(_onDeleteAnnotation);
    on<SearchAnnotationsEvent>(_onSearchAnnotations);
    on<HighlightAnnotationEvent>(_onHighlightAnnotation);
    on<ClearAnnotationHighlightEvent>(_onClearAnnotationHighlight);
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
        expandedFolders: const {},
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
        final fullContent = await repository.readFileContent(event.filePath);

        // Parse to separate content from annotations
        String displayContent = fullContent;
        List<Annotation> annotations = [];

        if (annotationService != null && event.filePath.endsWith('.md')) {
          // Get annotations (this parses the file)
          annotations = await annotationService!.getAnnotationsForFile(event.filePath);

          // Parse to get just the content part (without annotations section)
          final parsed = annotationService!.parser.parse(fullContent, event.filePath);
          displayContent = parsed.content;

          AppLogger.debug(
            'Loaded file with ${annotations.length} annotations',
            tag: 'DocumentationBloc',
            data: event.filePath,
          );
        }

        // Emit loaded content and annotations
        emit(currentState.copyWith(
          selectedFilePath: event.filePath,
          currentContent: displayContent,
          isLoadingContent: false,
          annotations: annotations,
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

  // ============================================================================
  // Annotation Event Handlers
  // ============================================================================

  /// Handles loading annotations for a file
  Future<void> _onLoadAnnotations(
    LoadAnnotationsEvent event,
    Emitter<DocumentationState> emit,
  ) async {
    if (annotationService == null) return;

    final currentState = state;

    if (currentState is DocumentationLoaded) {
      emit(currentState.copyWith(isLoadingAnnotations: true));

      try {
        final annotations = await annotationService!.getAnnotationsForFile(
          event.filePath,
        );

        emit(currentState.copyWith(
          annotations: annotations,
          isLoadingAnnotations: false,
        ));
      } catch (e) {
        AppLogger.error(
          'Failed to load annotations',
          tag: 'DocumentationBloc',
          error: e,
        );
        emit(currentState.copyWith(
          isLoadingAnnotations: false,
        ));
      }
    }
  }

  /// Handles adding a new annotation
  Future<void> _onAddAnnotation(
    AddAnnotationEvent event,
    Emitter<DocumentationState> emit,
  ) async {
    if (annotationService == null) {
      AppLogger.warning(
        'AddAnnotationEvent received but annotationService is null',
        tag: 'DocumentationBloc',
      );
      return;
    }

    AppLogger.info(
      'AddAnnotationEvent received',
      tag: 'DocumentationBloc',
      data: 'File: ${event.filePath}, Anchor: "${event.anchorText}", Content: "${event.content}"',
    );

    try {
      await annotationService!.addAnnotation(
        filePath: event.filePath,
        anchorText: event.anchorText,
        lineNumber: event.lineNumber,
        content: event.content,
        color: event.color,
        tags: event.tags,
      );

      AppLogger.success(
        'Annotation added successfully',
        tag: 'DocumentationBloc',
      );

      // Reload file content (which will also reload annotations)
      add(SelectFileEvent(filePath: event.filePath));
    } catch (e) {
      AppLogger.error(
        'Failed to add annotation',
        tag: 'DocumentationBloc',
        error: e,
      );
      emit(DocumentationError(
        message: 'Failed to add annotation',
        error: e,
      ));
    }
  }

  /// Handles updating an existing annotation
  Future<void> _onUpdateAnnotation(
    UpdateAnnotationEvent event,
    Emitter<DocumentationState> emit,
  ) async {
    if (annotationService == null) return;

    final currentState = state;

    if (currentState is DocumentationLoaded) {
      try {
        // Find the existing annotation
        final existingAnnotation = currentState.annotations.firstWhere(
          (a) => a.id == event.annotationId,
        );

        // Create updated annotation
        final updatedAnnotation = existingAnnotation.copyWith(
          anchorText: event.anchorText,
          lineNumber: event.lineNumber,
          content: event.content,
          color: event.color,
          tags: event.tags,
          updatedAt: DateTime.now(),
        );

        await annotationService!.updateAnnotation(updatedAnnotation);

        // Reload annotations
        add(LoadAnnotationsEvent(filePath: event.filePath));

        // Reload file content
        add(SelectFileEvent(filePath: event.filePath));

        AppLogger.success(
          'Annotation updated',
          tag: 'DocumentationBloc',
        );
      } catch (e) {
        AppLogger.error(
          'Failed to update annotation',
          tag: 'DocumentationBloc',
          error: e,
        );
        emit(DocumentationError(
          message: 'Failed to update annotation',
          error: e,
        ));
      }
    }
  }

  /// Handles deleting an annotation
  Future<void> _onDeleteAnnotation(
    DeleteAnnotationEvent event,
    Emitter<DocumentationState> emit,
  ) async {
    if (annotationService == null) return;

    try {
      await annotationService!.deleteAnnotation(
        event.filePath,
        event.annotationId,
      );

      // Reload annotations
      add(LoadAnnotationsEvent(filePath: event.filePath));

      // Reload file content
      add(SelectFileEvent(filePath: event.filePath));

      AppLogger.success(
        'Annotation deleted',
        tag: 'DocumentationBloc',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to delete annotation',
        tag: 'DocumentationBloc',
        error: e,
      );
      emit(DocumentationError(
        message: 'Failed to delete annotation',
        error: e,
      ));
    }
  }

  /// Handles searching annotations
  Future<void> _onSearchAnnotations(
    SearchAnnotationsEvent event,
    Emitter<DocumentationState> emit,
  ) async {
    if (annotationService == null) return;

    final currentState = state;

    if (currentState is DocumentationLoaded) {
      try {
        final results = await annotationService!.searchAnnotations(event.query);

        AppLogger.info(
          'Found ${results.length} annotations matching "${event.query}"',
          tag: 'DocumentationBloc',
        );

        // Could emit a specific state with search results if needed
        // For now, just log the results
      } catch (e) {
        AppLogger.error(
          'Failed to search annotations',
          tag: 'DocumentationBloc',
          error: e,
        );
      }
    }
  }

  /// Handles highlighting an annotation
  Future<void> _onHighlightAnnotation(
    HighlightAnnotationEvent event,
    Emitter<DocumentationState> emit,
  ) async {
    final currentState = state;

    if (currentState is DocumentationLoaded) {
      emit(currentState.copyWith(
        highlightedAnnotationId: event.annotationId,
      ));
    }
  }

  /// Handles clearing annotation highlight
  Future<void> _onClearAnnotationHighlight(
    ClearAnnotationHighlightEvent event,
    Emitter<DocumentationState> emit,
  ) async {
    final currentState = state;

    if (currentState is DocumentationLoaded) {
      emit(currentState.copyWith(
        clearHighlight: true,
      ));
    }
  }
}
