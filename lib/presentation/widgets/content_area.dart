import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../application/bloc/documentation_bloc.dart';
import '../../application/bloc/documentation_event.dart';
import '../../application/bloc/documentation_state.dart';
import '../../domain/entities/markdown_style_preferences.dart';
import '../../infrastructure/services/app_logger.dart';
import 'markdown_viewer.dart';
import 'mermaid_file_viewer.dart';
import 'annotation_dialog.dart';
import 'annotations_sidebar.dart';
import 'annotation_gutter.dart';
import 'positioned_annotation_gutter.dart';
import '../theme/seez_theme.dart';
import '../theme/app_theme.dart';

/// Content area with animated transitions for markdown display
class ContentArea extends StatefulWidget {
  final MarkdownStylePreferences markdownStyles;
  final String currentTheme;

  const ContentArea({
    super.key,
    required this.markdownStyles,
    required this.currentTheme,
  });

  @override
  State<ContentArea> createState() => _ContentAreaState();
}

class _ContentAreaState extends State<ContentArea> {
  bool _isGutterCollapsed = false;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _annotationKeys = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Get or create a GlobalKey for an annotation
  GlobalKey _getAnnotationKey(String annotationId) {
    if (!_annotationKeys.containsKey(annotationId)) {
      _annotationKeys[annotationId] = GlobalKey();
    }
    return _annotationKeys[annotationId]!;
  }

  int _calculateTotalLines(String content) {
    if (content.isEmpty) return 0;
    return content.split('\n').length;
  }

  void _scrollToAnnotation(annotation) {
    AppLogger.info(
      'Attempting to scroll to annotation',
      tag: 'ContentArea',
      data: 'ID: ${annotation.id}, Anchor: "${annotation.anchorText}", Line: ${annotation.lineNumber}',
    );

    // Get the GlobalKey for this annotation
    final key = _getAnnotationKey(annotation.id);

    AppLogger.debug(
      'Got GlobalKey for annotation',
      tag: 'ContentArea',
      data: 'Key: $key, HasContext: ${key.currentContext != null}',
    );

    // Wait for the next frame to ensure widgets are built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptScroll(annotation, key);
    });
  }

  void _attemptScroll(annotation, GlobalKey key) {
    try {
      // Get the RenderBox from the GlobalKey
      final context = key.currentContext;

      AppLogger.debug(
        'Checking GlobalKey context',
        tag: 'ContentArea',
        data: 'ID: ${annotation.id}, Context: ${context != null ? "exists" : "null"}',
      );

      if (context == null) {
        AppLogger.warning(
          'GlobalKey context is null - marker might not be in rendered content',
          tag: 'ContentArea',
          data: 'ID: ${annotation.id}, Anchor: "${annotation.anchorText}"',
        );
        _scrollToLine(annotation.lineNumber ?? 1);
        return;
      }

      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;

      if (renderBox != null) {
        AppLogger.debug(
          'Found RenderBox',
          tag: 'ContentArea',
          data: 'ID: ${annotation.id}, Size: ${renderBox.size}',
        );

        // Get the position of the annotation marker relative to the scroll view
        final RenderObject? scrollViewRenderObject =
            _scrollController.position.context.storageContext.findRenderObject();

        if (scrollViewRenderObject is RenderBox) {
          // Calculate the offset of the annotation marker
          final offset = renderBox.localToGlobal(Offset.zero, ancestor: scrollViewRenderObject);

          AppLogger.debug(
            'Calculated offset',
            tag: 'ContentArea',
            data: 'ID: ${annotation.id}, Offset: $offset, Current scroll: ${_scrollController.offset}',
          );

          // Calculate target scroll position
          // Subtract some offset to show context above the annotation
          final targetPosition = _scrollController.offset + offset.dy - 100;

          // Clamp to valid scroll range
          final maxScroll = _scrollController.position.maxScrollExtent;
          final clampedPosition = targetPosition.clamp(0.0, maxScroll);

          AppLogger.info(
            'Scrolling to annotation using GlobalKey',
            tag: 'ContentArea',
            data: 'ID: ${annotation.id}, Target: ${targetPosition.toStringAsFixed(1)}, Clamped: ${clampedPosition.toStringAsFixed(1)}',
          );

          _scrollController.animateTo(
            clampedPosition,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          AppLogger.warning(
            'Could not find scroll view RenderBox',
            tag: 'ContentArea',
            data: 'ID: ${annotation.id}',
          );
          _scrollToLine(annotation.lineNumber ?? 1);
        }
      } else {
        AppLogger.warning(
          'RenderBox is null',
          tag: 'ContentArea',
          data: 'ID: ${annotation.id}',
        );
        _scrollToLine(annotation.lineNumber ?? 1);
      }
    } catch (e) {
      AppLogger.error(
        'Error scrolling to annotation',
        tag: 'ContentArea',
        data: 'ID: ${annotation.id}, Error: $e',
      );
      _scrollToLine(annotation.lineNumber ?? 1);
    }
  }

  /// Fallback: scroll to a specific line number
  void _scrollToLine(int lineNumber) {
    final baseFontSize = widget.markdownStyles.baseFontSize;
    final baseLineHeight = baseFontSize * 1.6;
    final estimatedPosition = lineNumber * baseLineHeight;

    AppLogger.info(
      'Fallback: Scrolling to line number',
      tag: 'ContentArea',
      data: 'Line: $lineNumber, Estimated position: ${estimatedPosition.toStringAsFixed(1)}',
    );

    _scrollController.animateTo(
      estimatedPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Color get _backgroundColor {
    return widget.currentTheme == 'seez'
        ? SeezTheme.parchmentBackground
        : (widget.currentTheme == 'dark'
            ? AppTheme.darkerBackground
            : AppTheme.lightBackground);
  }

  Color get _textColor {
    return widget.currentTheme == 'seez'
        ? SeezTheme.darkBrownText
        : (widget.currentTheme == 'dark'
            ? AppTheme.textOnDark
            : AppTheme.textPrimary);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
      child: BlocBuilder<DocumentationBloc, DocumentationState>(
        builder: (context, state) {
          if (state is DocumentationError) {
            return _buildErrorView(state.message);
          }

          if (state is DocumentationLoaded) {
            if (state.selectedFilePath == null) {
              return _buildEmptyState();
            }

            if (state.isLoadingContent) {
              return _buildLoadingView();
            }

            if (state.currentContent == null) {
              return _buildEmptyState();
            }

            // Animated content transitions with annotations
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.02, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _buildContentWithAnnotations(context, state),
            );
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildContentWithAnnotations(
    BuildContext context,
    DocumentationLoaded state,
  ) {
    // Show gutter only for markdown files with annotations
    final showGutter = state.selectedFilePath != null &&
        state.selectedFilePath!.endsWith('.md') &&
        state.annotations.isNotEmpty;

    return Stack(
      children: [
        // Layout with optional annotation gutter
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left annotation gutter with collapse toggle inside
            if (showGutter)
              PositionedAnnotationGutter(
                annotations: state.annotations,
                currentTheme: widget.currentTheme,
                isCollapsed: _isGutterCollapsed,
                onToggleCollapse: () {
                  setState(() {
                    _isGutterCollapsed = !_isGutterCollapsed;
                  });
                },
                onAnnotationTap: (annotation) {
                  // Scroll to the annotation location
                  _scrollToAnnotation(annotation);
                  // Then show details
                  Future.delayed(const Duration(milliseconds: 600), () {
                    _showAnnotationDetails(context, state, annotation);
                  });
                },
                totalLines: _calculateTotalLines(state.currentContent ?? ''),
                lineHeight: widget.markdownStyles.baseFontSize * 1.6, // line height
                topPadding: 24.0,
              ),

            // Main content
            Expanded(
              child: _buildContentViewer(state),
            ),
          ],
        ),

        // Floating action button for adding annotations
        if (state.selectedFilePath != null &&
            state.selectedFilePath!.endsWith('.md'))
          Positioned(
            right: 20,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: () => _showAddAnnotationDialog(context, state),
              backgroundColor: widget.currentTheme == 'seez'
                  ? SeezTheme.primaryBrown
                  : AppTheme.primaryBlue,
              child: const Icon(CupertinoIcons.add, color: Colors.white),
            ),
          ),

        // Annotations count badge
        if (state.annotations.isNotEmpty)
          Positioned(
            right: 20,
            top: 20,
            child: GestureDetector(
              onTap: () => _showAnnotationsSidebar(context, state),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.currentTheme == 'seez'
                      ? SeezTheme.primaryBrown
                      : AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      CupertinoIcons.bookmark_fill,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${state.annotations.length}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContentViewer(DocumentationLoaded state) {
    final filePath = state.selectedFilePath!;
    final isMermaidFile = filePath.endsWith('.mermaid');
    final fileName = filePath.split('/').last;

    if (isMermaidFile) {
      return SingleChildScrollView(
        key: ValueKey(filePath),
        child: MermaidFileViewer(
          content: state.currentContent!,
          currentTheme: widget.currentTheme,
          fileName: fileName,
        ),
      );
    }

    // Ensure GlobalKeys exist for all annotations
    for (var annotation in state.annotations) {
      _getAnnotationKey(annotation.id);
    }

    // Default to markdown viewer for .md files
    return SingleChildScrollView(
      key: ValueKey(filePath),
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      child: MarkdownViewer(
        content: state.currentContent!,
        stylePreferences: widget.markdownStyles,
        currentTheme: widget.currentTheme,
        annotations: state.annotations,
        annotationKeys: _annotationKeys,
        onTextSelected: (selectedText, widgetContext) {
          _showAddAnnotationDialog(context, state, selectedText: selectedText);
        },
      ),
    );
  }

  void _showAddAnnotationDialog(
    BuildContext context,
    DocumentationLoaded state, {
    String? selectedText,
  }) async {
    AppLogger.info(
      '_showAddAnnotationDialog called',
      tag: 'ContentArea',
      data: 'File: ${state.selectedFilePath}, Selected text: "$selectedText"',
    );

    // Capture the bloc reference BEFORE opening dialog
    final bloc = context.read<DocumentationBloc>();

    final result = await showDialog<AnnotationDialogResult>(
      context: context,
      builder: (context) => AnnotationDialog(
        currentTheme: widget.currentTheme,
        selectedText: selectedText,
      ),
    );

    AppLogger.info(
      'Dialog result',
      tag: 'ContentArea',
      data: 'Result: ${result != null ? "has data" : "null"}, FilePath: ${state.selectedFilePath}',
    );

    if (result != null && state.selectedFilePath != null) {
      AppLogger.info(
        'Dispatching AddAnnotationEvent',
        tag: 'ContentArea',
        data: 'File: ${state.selectedFilePath!}, Anchor: "${result.anchorText}"',
      );

      bloc.add(
        AddAnnotationEvent(
          filePath: state.selectedFilePath!,
          anchorText: result.anchorText,
          content: result.content,
          color: result.color,
          tags: result.tags,
        ),
      );
    } else {
      AppLogger.warning(
        'AddAnnotationEvent NOT dispatched',
        tag: 'ContentArea',
        data: 'Result null: ${result == null}, FilePath null: ${state.selectedFilePath == null}',
      );
    }
  }

  void _showAnnotationDetails(
    BuildContext context,
    DocumentationLoaded state,
    annotation,
  ) async {
    // Capture the bloc reference BEFORE opening dialog
    final bloc = context.read<DocumentationBloc>();

    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              CupertinoIcons.bookmark_fill,
              color: _getAnnotationColor(annotation.color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                annotation.anchorText,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              annotation.content,
              style: GoogleFonts.inter(fontSize: 14),
            ),
            if (annotation.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: annotation.tags.map<Widget>((tag) {
                  return Chip(
                    label: Text('#$tag'),
                    backgroundColor: _getAnnotationColor(annotation.color)
                        .withValues(alpha: 0.2),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Line ${annotation.lineNumber ?? "N/A"}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'edit'),
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'delete'),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );

    // Handle the action after dialog is closed
    if (action == 'edit') {
      _showEditAnnotationDialog(context, state, annotation);
    } else if (action == 'delete') {
      if (state.selectedFilePath != null) {
        bloc.add(
          DeleteAnnotationEvent(
            filePath: state.selectedFilePath!,
            annotationId: annotation.id,
          ),
        );
      }
    }
  }

  Color _getAnnotationColor(String color) {
    switch (color.toLowerCase()) {
      case 'yellow':
        return const Color(0xFFFFD700);
      case 'red':
        return const Color(0xFFFF6B6B);
      case 'blue':
        return const Color(0xFF4ECDC4);
      case 'green':
        return const Color(0xFF95E1D3);
      case 'orange':
        return const Color(0xFFFFAA5A);
      case 'purple':
        return const Color(0xFFB695F8);
      default:
        return const Color(0xFFFFD700);
    }
  }

  void _showAnnotationsSidebar(
    BuildContext context,
    DocumentationLoaded state,
  ) {
    // Capture the bloc context before opening bottom sheet
    final bloc = context.read<DocumentationBloc>();

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Annotations',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark),
                  onPressed: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: AnnotationsSidebar(
                annotations: state.annotations,
                currentTheme: widget.currentTheme,
                onAnnotationTap: (annotation) {
                  Navigator.pop(sheetContext);
                  _showAnnotationDetails(context, state, annotation);
                },
                onEditAnnotation: (annotation) {
                  Navigator.pop(sheetContext);
                  _showEditAnnotationDialog(context, state, annotation);
                },
                onDeleteAnnotation: (annotationId) {
                  if (state.selectedFilePath != null) {
                    bloc.add(
                      DeleteAnnotationEvent(
                        filePath: state.selectedFilePath!,
                        annotationId: annotationId,
                      ),
                    );
                    // Close the bottom sheet after deleting
                    Navigator.pop(sheetContext);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAnnotationDialog(
    BuildContext context,
    DocumentationLoaded state,
    annotation,
  ) async {
    // Capture the bloc reference BEFORE opening dialog
    final bloc = context.read<DocumentationBloc>();

    final result = await showDialog<AnnotationDialogResult>(
      context: context,
      builder: (context) => AnnotationDialog(
        existingAnnotation: annotation,
        currentTheme: widget.currentTheme,
      ),
    );

    if (result != null && state.selectedFilePath != null) {
      bloc.add(
        UpdateAnnotationEvent(
          filePath: state.selectedFilePath!,
          annotationId: annotation.id,
          anchorText: result.anchorText,
          content: result.content,
          color: result.color,
          tags: result.tags,
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.doc_text,
            size: 80,
            color: _textColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'Select a file to view',
            style: GoogleFonts.inter(
              fontSize: 18,
              color: _textColor.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a markdown or mermaid file from the sidebar',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _textColor.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: widget.currentTheme == 'seez'
                ? SeezTheme.primaryBrown
                : AppTheme.primaryBlue,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading content...',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _textColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: widget.currentTheme == 'seez'
                  ? SeezTheme.danger
                  : AppTheme.danger,
            ),
            const SizedBox(height: 24),
            Text(
              'Error Loading Content',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _textColor.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
