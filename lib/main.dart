import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:doc_viewer_app/features/documentation/domain/entities/markdown_style_preferences.dart';
import 'core/utils/preferences_service.dart';
import 'core/theme/seez_theme.dart';
import 'core/theme/app_theme.dart';
import 'presentation/widgets/help_dialog.dart';
import 'core/routing/app_router.dart';

void main() {
  runApp(const FlorenceDocsApp());
}

class FlorenceDocsApp extends StatefulWidget {
  const FlorenceDocsApp({super.key});

  @override
  State<FlorenceDocsApp> createState() => _FlorenceDocsAppState();
}

class _FlorenceDocsAppState extends State<FlorenceDocsApp> {
  // State notifiers for routing
  final ValueNotifier<String?> _selectedDocsPath = ValueNotifier(null);
  final ValueNotifier<String> _currentTheme = ValueNotifier('seez');
  final ValueNotifier<MarkdownStylePreferences> _markdownStyles =
      ValueNotifier(const MarkdownStylePreferences());

  final PreferencesService _prefsService = PreferencesService();
  static const MethodChannel _menuChannel =
      MethodChannel('com.florence.docs/menu');

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _setupMenuChannel();

    // Create router with state notifiers
    _router = AppRouter.createRouter(
      selectedDocsPath: _selectedDocsPath,
      currentTheme: _currentTheme,
      markdownStyles: _markdownStyles,
    );
  }

  @override
  void dispose() {
    _selectedDocsPath.dispose();
    _currentTheme.dispose();
    _markdownStyles.dispose();
    super.dispose();
  }

  void _setupMenuChannel() {
    _menuChannel.setMethodCallHandler((call) async {
      if (call.method == 'showHelp') {
        // Get current context from router
        final context = _router.routerDelegate.navigatorKey.currentContext;
        if (context != null) {
          showDialog(
            context: context,
            builder: (context) => const HelpDialog(),
          );
        }
      }
    });
  }

  Future<void> _loadPreferences() async {
    final theme = await _prefsService.getTheme();
    final styles = await _prefsService.getMarkdownStyles();

    _currentTheme.value = theme;
    _markdownStyles.value = styles;

    // Save preferences when they change
    _currentTheme.addListener(() {
      _prefsService.setTheme(_currentTheme.value);
    });
    _markdownStyles.addListener(() {
      _prefsService.setMarkdownStyles(_markdownStyles.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _currentTheme,
      builder: (context, theme, _) {
        final currentThemeData = theme == 'seez'
            ? SeezTheme.lightTheme
            : (theme == 'dark' ? AppTheme.darkTheme : AppTheme.lightTheme);

        return AnimatedTheme(
          data: currentThemeData,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: MaterialApp.router(
            title: 'Florence Documentation',
            debugShowCheckedModeBanner: false,
            theme: currentThemeData,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme == 'dark' ? ThemeMode.dark : ThemeMode.light,
            routerConfig: _router,
          ),
        );
      },
    );
  }
}
