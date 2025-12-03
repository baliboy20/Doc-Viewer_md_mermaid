import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/seez_theme.dart';
import '../widgets/sidebar_area.dart';
import '../widgets/content_area.dart';
import '../widgets/style_settings_dialog.dart';
import '../../domain/entities/markdown_style_preferences.dart';

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

  void _showThemeMenu() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 200,
        80,
        20,
        0,
      ),
      items: [
        PopupMenuItem(
          value: 'seez',
          child: Row(
            children: [
              Icon(
                widget.currentTheme == 'seez' ? CupertinoIcons.checkmark_alt : CupertinoIcons.circle,
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
                widget.currentTheme == 'light' ? CupertinoIcons.checkmark_alt : CupertinoIcons.circle,
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
                widget.currentTheme == 'dark' ? CupertinoIcons.checkmark_alt : CupertinoIcons.circle,
                size: 16,
                color: SeezTheme.primaryBrown,
              ),
              const SizedBox(width: 8),
              const Text('Dark Theme'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        widget.onThemeChanged(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Animated Gradient Header
          Container(
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
                // Animated Floating Circles
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    final offset1 = _animationController.value * 15;
                    final offset2 = (1 - _animationController.value) * 20;
                    final offset3 = _animationController.value * 25;

                    return Stack(
                      children: [
                        // Circle 1
                        Positioned(
                          left: 80 + offset1,
                          top: -20,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFF8B4513).withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Circle 2
                        Positioned(
                          right: 150 + offset2,
                          top: -30,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFF8B2500).withValues(alpha: 0.25),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Circle 3
                        Positioned(
                          left: 300 + offset3,
                          top: -10,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  SeezTheme.darkBrownText.withValues(alpha: 0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Header Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // App Title
                      Text(
                        'Rome Doc Viewer',
                        style: GoogleFonts.pacifico(
                          color: const Color(0xFFFAF5ED),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            const Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black38,
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Root Path Display
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.folder,
                                size: 14,
                                color: Colors.white.withValues(alpha: 0.95),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  widget.docsRootPath.split('/').last,
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Change Folder Button
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.folder_open,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                        onPressed: widget.onChangeFolder,
                        tooltip: 'Change Folder',
                      ),

                      // Theme Selector Button
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.paintbrush,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                        onPressed: _showThemeMenu,
                        tooltip: 'Change Theme',
                      ),

                      // Style Settings Button
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.settings,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                        onPressed: _showStyleSettings,
                        tooltip: 'Style Settings',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area with Sidebar
          Expanded(
            child: Row(
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
          ),
        ],
      ),
    );
  }
}
