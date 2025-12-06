import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doc_viewer_app/core/theme/seez_theme.dart';
import '../widgets/sidebar_area.dart';
import '../widgets/content_area.dart';
import '../widgets/style_settings_dialog.dart';
import '../../domain/entities/markdown_style_preferences.dart';
import '../../application/bloc/documentation_bloc.dart';
import '../../application/bloc/documentation_event.dart';

/// Main documentation viewer screen with animated header and layout
class DocumentationScreen extends StatefulWidget {
  final VoidCallback onChangeFolder;
  final String currentTheme;
  final Function(String) onThemeChanged;
  final MarkdownStylePreferences markdownStyles;
  final Function(MarkdownStylePreferences) onStylesChanged;
  final String docsRootPath;

  const DocumentationScreen({
    super.key,
    required this.onChangeFolder,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.markdownStyles,
    required this.onStylesChanged,
    required this.docsRootPath,
  });

  @override
  State<DocumentationScreen> createState() => _DocumentationScreenState();
}

class _DocumentationScreenState extends State<DocumentationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showStyleSettings() {
    showDialog(
      context: context,
      builder: (context) => StyleSettingsDialog(
        currentStyles: widget.markdownStyles,
        onStylesChanged: widget.onStylesChanged,
      ),
    );
  }

  void _refreshFileTree() {
    context.read<DocumentationBloc>().add(RefreshFileTreeEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DocumentationAppBar(
        animationController: _animationController,
        docsRootPath: widget.docsRootPath,
        onChangeFolder: widget.onChangeFolder,
        onRefreshFileTree: _refreshFileTree,
        currentTheme: widget.currentTheme,
        onThemeChanged: widget.onThemeChanged,
        onStyleSettings: _showStyleSettings,
      ),
      body: Row(
        children: [
          // Sidebar Area
          SidebarArea(
            currentTheme: widget.currentTheme,
          ),

          // Content Area
          Expanded(
            child: ContentArea(
              markdownStyles: widget.markdownStyles,
              currentTheme: widget.currentTheme,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom AppBar with animated gradient header
class DocumentationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AnimationController animationController;
  final String docsRootPath;
  final VoidCallback onChangeFolder;
  final VoidCallback onRefreshFileTree;
  final String currentTheme;
  final Function(String) onThemeChanged;
  final VoidCallback onStyleSettings;

  const DocumentationAppBar({
    super.key,
    required this.animationController,
    required this.docsRootPath,
    required this.onChangeFolder,
    required this.onRefreshFileTree,
    required this.currentTheme,
    required this.onThemeChanged,
    required this.onStyleSettings,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SeezTheme.primaryBrown,
            SeezTheme.mediumBrownBorder,
            SeezTheme.primaryBrown.withValues(alpha: 0.8),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated floating circles
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: FloatingCirclesPainter(
                  animationValue: animationController.value,
                ),
                size: const Size(double.infinity, 60),
              );
            },
          ),

          // Header content
          Padding(
            padding: const EdgeInsets.fromLTRB(36, 15, 4, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo/Title
                Text(
                  'Rome Doc Viewer',
                  style: GoogleFonts.pacifico(
                    fontSize: 26,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.95),
                    letterSpacing: 0.5,
                    shadows: [
                      const Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black26,
                      ),
                      ],
                  ),
                ),

                const SizedBox(width: 138),

                // Folder path
                Expanded(

                  child: Text(
                    docsRootPath,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                      fontStyle: FontStyle.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 8),

                // Change Folder button
                IconButton(
                  icon: Icon(
                    CupertinoIcons.folder,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                  tooltip: 'Change Documentation Folder',
                  onPressed: onChangeFolder,
                ),

                const SizedBox(width: 8),

                // Refresh button
                IconButton(
                  icon: Icon(
                    CupertinoIcons.refresh,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                  tooltip: 'Refresh File Tree',
                  onPressed: onRefreshFileTree,
                ),

                const SizedBox(width: 8),

                // Style settings button
                IconButton(
                  icon: Icon(
                    CupertinoIcons.textformat,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                  tooltip: 'Style Settings',
                  onPressed: onStyleSettings,
                ),

                const SizedBox(width: 8),

                // Theme menu
                ThemeMenuButton(
                  currentTheme: currentTheme,
                  onThemeChanged: onThemeChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for animated floating circles in header
class FloatingCirclesPainter extends CustomPainter {
  final double animationValue;

  FloatingCirclesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Circle 1
    final offset1 = Offset(
      size.width * 0.2 + (animationValue * 30),
      size.height * 0.3 + (animationValue * 10),
    );
    canvas.drawCircle(offset1, 40, paint);

    // Circle 2
    final offset2 = Offset(
      size.width * 0.6 - (animationValue * 20),
      size.height * 0.6 - (animationValue * 15),
    );
    canvas.drawCircle(offset2, 30, paint);

    // Circle 3
    final offset3 = Offset(
      size.width * 0.85 + (animationValue * 15),
      size.height * 0.4 + (animationValue * 20),
    );
    canvas.drawCircle(offset3, 35, paint);
  }

  @override
  bool shouldRepaint(FloatingCirclesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Stateless widget for theme selection menu
class ThemeMenuButton extends StatelessWidget {
  final String currentTheme;
  final Function(String) onThemeChanged;

  const ThemeMenuButton({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        CupertinoIcons.paintbrush,
        color: Colors.white.withValues(alpha: 0.95),
      ),
      tooltip: 'Change Theme',
      onSelected: onThemeChanged,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'seez',
          child: Row(
            children: [
              Icon(
                currentTheme == 'seez' ? CupertinoIcons.checkmark_alt : CupertinoIcons.circle,
                size: 16,
                color: SeezTheme.primaryBrown,
              ),
              const SizedBox(width: 8),
              const Text('Seez Theme'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'light',
          child: Row(
            children: [
              Icon(
                currentTheme == 'light' ? CupertinoIcons.checkmark_alt : CupertinoIcons.circle,
                size: 16,
                color: SeezTheme.primaryBrown,
              ),
              const SizedBox(width: 8),
              const Text('Light Theme'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'dark',
          child: Row(
            children: [
              Icon(
                currentTheme == 'dark' ? CupertinoIcons.checkmark_alt : CupertinoIcons.circle,
                size: 16,
                color: SeezTheme.primaryBrown,
              ),
              const SizedBox(width: 8),
              const Text('Dark Theme'),
            ],
          ),
        ),
      ],
    );
  }
}
