import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../application/bloc/documentation_bloc.dart';
import '../../application/bloc/documentation_event.dart';
import '../../application/bloc/documentation_state.dart';
import '../../domain/entities/file_node.dart';
import '../../infrastructure/services/app_logger.dart';
import '../theme/seez_theme.dart';
import '../theme/app_theme.dart';

/// Resizable sidebar navigation showing file tree
/// Features: hover effects, chevron rotation, drag-to-resize, context menus
class SidebarNavigation extends StatefulWidget {
  final String currentTheme;

  const SidebarNavigation({
    super.key,
    required this.currentTheme,
  });

  @override
  State<SidebarNavigation> createState() => _SidebarNavigationState();
}

class _SidebarNavigationState extends State<SidebarNavigation> {
  double _sidebarWidth = 280.0;
  static const double _minWidth = 200.0;
  static const double _maxWidth = 600.0;
  String? _hoveredPath;

  Color get _backgroundColor {
    return widget.currentTheme == 'seez'
        ? SeezTheme.lightBeigeGradient1
        : (widget.currentTheme == 'dark'
            ? AppTheme.darkBackground
            : AppTheme.lighterBackground);
  }

  Color get _borderColor {
    return widget.currentTheme == 'seez'
        ? SeezTheme.mediumBrownBorder
        : (widget.currentTheme == 'dark'
            ? AppTheme.borderDark
            : AppTheme.border);
  }

  Color get _textColor {
    return widget.currentTheme == 'seez'
        ? SeezTheme.darkBrownText
        : (widget.currentTheme == 'dark'
            ? AppTheme.textOnDark
            : AppTheme.textPrimary);
  }

  Color get _hoverColor {
    return widget.currentTheme == 'seez'
        ? SeezTheme.lightBeigeGradient2
        : (widget.currentTheme == 'dark'
            ? AppTheme.borderDark
            : AppTheme.hoverItem);
  }

  Color get _selectedColor {
    return widget.currentTheme == 'seez'
        ? SeezTheme.primaryBrown.withValues(alpha: 0.1)
        : (widget.currentTheme == 'dark'
            ? AppTheme.primaryBlue.withValues(alpha: 0.2)
            : AppTheme.selectedItem);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sidebar Content
        Container(
          width: _sidebarWidth,
          decoration: BoxDecoration(
            color: _backgroundColor,
            border: Border(
              right: BorderSide(
                color: _borderColor,
                width: 1,
              ),
            ),
          ),
          child: BlocBuilder<DocumentationBloc, DocumentationState>(
            builder: (context, state) {
              if (state is DocumentationError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: widget.currentTheme == 'seez'
                              ? SeezTheme.danger
                              : AppTheme.danger,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading files',
                          style: GoogleFonts.aBeeZee(
                            color: _textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: GoogleFonts.aBeeZee(
                            color: _textColor.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is DocumentationLoaded) {
                if (state.fileTree.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No markdown files found',
                        style: GoogleFonts.aBeeZee(
                          color: _textColor.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: state.fileTree
                      .map((node) => _buildFileNode(context, node, state, 0))
                      .toList(),
                );
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),

        // Resize Handle
        GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              _sidebarWidth = (_sidebarWidth + details.delta.dx)
                  .clamp(_minWidth, _maxWidth);
            });
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: Container(
              width: 6,
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: 2,
                  color: _borderColor.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFileNode(
    BuildContext context,
    FileNode node,
    DocumentationLoaded state,
    int depth,
  ) {
    final isHovered = _hoveredPath == node.path;
    final isSelected = state.selectedFilePath == node.path;
    final isExpanded = state.expandedFolders.contains(node.path);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // File/Folder Item
        MouseRegion(
          onEnter: (_) => setState(() => _hoveredPath = node.path),
          onExit: (_) => setState(() => _hoveredPath = null),
          child: GestureDetector(
            onTap: () {
              if (node.isDirectory) {
                context.read<DocumentationBloc>().add(
                      ToggleFolderEvent(folderPath: node.path),
                    );
              } else {
                context.read<DocumentationBloc>().add(
                      SelectFileEvent(filePath: node.path),
                    );
              }
            },
            onSecondaryTapDown: (details) {
              _showContextMenu(context, node, details.globalPosition);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(
                left: 8 + (depth * 16.0),
                right: 8,
                top: 2,
                bottom: 2,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? _selectedColor
                    : (isHovered ? _hoverColor : Colors.transparent),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  // Folder Chevron or File Icon
                  if (node.isDirectory) ...[
                    AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        CupertinoIcons.chevron_right,
                        size: 14,
                        color: _textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded ? CupertinoIcons.folder_open : CupertinoIcons.folder_solid,
                      size: 18,
                      color: widget.currentTheme == 'seez'
                          ? SeezTheme.primaryBrown
                          : AppTheme.primaryBlue,
                    ),
                  ] else ...[
                    const SizedBox(width: 22),
                    Icon(
                      node.name.endsWith('.mermaid')
                          ? CupertinoIcons.chart_bar_alt_fill
                          : CupertinoIcons.doc_text,
                      size: 16,
                      color: node.name.endsWith('.mermaid')
                          ? (widget.currentTheme == 'seez'
                              ? SeezTheme.subtitleBlue
                              : AppTheme.primaryBlue)
                          : _textColor.withValues(alpha: 0.6),
                    ),
                  ],

                  const SizedBox(width: 8),

                  // File/Folder Name
                  Expanded(
                    child: Text(
                      node.name,
                      style: GoogleFonts.aBeeZee(
                        fontSize: 13,
                        color: _textColor,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // File Count Badge for Folders
                  if (node.isDirectory && node.children.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _textColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${node.children.length}',
                        style: GoogleFonts.aBeeZee(
                          fontSize: 10,
                          color: _textColor.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Child Nodes (if folder is expanded)
        if (node.isDirectory && isExpanded)
          ...node.children.map(
            (child) => _buildFileNode(context, child, state, depth + 1),
          ),
      ],
    );
  }

  void _showContextMenu(
    BuildContext context,
    FileNode node,
    Offset position,
  ) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + 1,
        position.dy + 1,
      ),
      items: [
        if (node.isDirectory)
          PopupMenuItem(
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.chevron_down_circle,
                  size: 16,
                  color: _textColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Expand All',
                  style: GoogleFonts.aBeeZee(fontSize: 13),
                ),
              ],
            ),
            onTap: () {
              // Expand all children recursively
              _expandAllChildren(context, node);
            },
          ),
        if (node.isDirectory)
          PopupMenuItem(
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.chevron_up_circle,
                  size: 16,
                  color: _textColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Collapse All',
                  style: GoogleFonts.aBeeZee(fontSize: 13),
                ),
              ],
            ),
            onTap: () {
              // Collapse all children recursively
              _collapseAllChildren(context, node);
            },
          ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                CupertinoIcons.doc_on_clipboard,
                size: 16,
                color: _textColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Copy Path',
                style: GoogleFonts.aBeeZee(fontSize: 13),
              ),
            ],
          ),
          onTap: () {
            _copyPathToClipboard(node.path);
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                CupertinoIcons.square_arrow_right,
                size: 16,
                color: _textColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Open in Terminal',
                style: GoogleFonts.aBeeZee(fontSize: 13),
              ),
            ],
          ),
          onTap: () {
            _openInTerminal(node.path, node.isDirectory);
          },
        ),
        PopupMenuItem(
          child: Row(
            children: [
              Icon(
                CupertinoIcons.folder_open,
                size: 16,
                color: _textColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Open in Android Studio',
                style: GoogleFonts.aBeeZee(fontSize: 13),
              ),
            ],
          ),
          onTap: () {
            _openInAndroidStudio(node.path);
          },
        ),
      ],
    );
  }

  void _expandAllChildren(BuildContext context, FileNode node) {
    final bloc = context.read<DocumentationBloc>();

    void expandRecursive(FileNode current) {
      if (current.isDirectory) {
        bloc.add(ToggleFolderEvent(folderPath: current.path, forceExpand: true));
        for (var child in current.children) {
          expandRecursive(child);
        }
      }
    }

    expandRecursive(node);
  }

  void _collapseAllChildren(BuildContext context, FileNode node) {
    final bloc = context.read<DocumentationBloc>();

    void collapseRecursive(FileNode current) {
      if (current.isDirectory) {
        for (var child in current.children) {
          collapseRecursive(child);
        }
        bloc.add(ToggleFolderEvent(folderPath: current.path, forceCollapse: true));
      }
    }

    collapseRecursive(node);
  }

  void _copyPathToClipboard(String path) async {
    try {
      await Clipboard.setData(ClipboardData(text: path));
      AppLogger.success('Path copied to clipboard', tag: 'Sidebar', data: path);
    } catch (e) {
      AppLogger.error(
        'Error copying path to clipboard',
        tag: 'Sidebar',
        error: e,
        data: path,
      );
    }
  }

  void _openInTerminal(String path, bool isDirectory) async {
    try {
      // Determine the target path
      // If it's a file, open the parent directory in Terminal
      final targetPath = isDirectory ? path : File(path).parent.path;

      AppLogger.info('Opening path in Terminal', tag: 'Sidebar', data: targetPath);

      // Use 'open' command on macOS to open Terminal at the specified path
      final result = await Process.run('open', [targetPath, '-a', 'Terminal']);

      if (result.exitCode == 0) {
        AppLogger.success('Opened in Terminal', tag: 'Sidebar', data: targetPath);
      } else {
        AppLogger.error(
          'Failed to open Terminal',
          tag: 'Sidebar',
          data: 'Exit code: ${result.exitCode}',
          error: result.stderr,
        );
      }
    } catch (e) {
      AppLogger.error(
        'Error opening Terminal',
        tag: 'Sidebar',
        error: e,
        data: path,
      );
    }
  }

  void _openInAndroidStudio(String path) async {
    try {
      AppLogger.info('Opening path in Android Studio', tag: 'Sidebar', data: path);

      // Use 'open' command on macOS to open with Android Studio
      final result = await Process.run('open', ['-a', 'Android Studio', path]);

      if (result.exitCode == 0) {
        AppLogger.success('Opened in Android Studio', tag: 'Sidebar', data: path);
      } else {
        AppLogger.error(
          'Failed to open Android Studio',
          tag: 'Sidebar',
          data: 'Exit code: ${result.exitCode}',
          error: result.stderr,
        );
      }
    } catch (e) {
      AppLogger.error(
        'Error opening Android Studio',
        tag: 'Sidebar',
        error: e,
        data: path,
      );
    }
  }
}
