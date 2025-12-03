import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../application/bloc/documentation_bloc.dart';
import '../../application/bloc/documentation_state.dart';
import '../../domain/entities/markdown_style_preferences.dart';
import 'markdown_viewer.dart';
import 'mermaid_file_viewer.dart';
import '../theme/seez_theme.dart';
import '../theme/app_theme.dart';

/// Content area with animated transitions for markdown display
class ContentArea extends StatelessWidget {
  final MarkdownStylePreferences markdownStyles;
  final String currentTheme;

  const ContentArea({
    super.key,
    required this.markdownStyles,
    required this.currentTheme,
  });

  Color get _backgroundColor {
    return currentTheme == 'seez'
        ? SeezTheme.parchmentBackground
        : (currentTheme == 'dark'
            ? AppTheme.darkerBackground
            : AppTheme.lightBackground);
  }

  Color get _textColor {
    return currentTheme == 'seez'
        ? SeezTheme.darkBrownText
        : (currentTheme == 'dark'
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

            // Animated content transitions
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
              child: _buildContentViewer(state),
            );
          }

          return _buildEmptyState();
        },
      ),
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
          currentTheme: currentTheme,
          fileName: fileName,
        ),
      );
    }

    // Default to markdown viewer for .md files
    return SingleChildScrollView(
      key: ValueKey(filePath),
      padding: const EdgeInsets.all(24),
      child: MarkdownViewer(
        content: state.currentContent!,
        stylePreferences: markdownStyles,
        currentTheme: currentTheme,
      ),
    );
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
            color: currentTheme == 'seez'
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
              color: currentTheme == 'seez'
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
