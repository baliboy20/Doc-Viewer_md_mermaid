import 'package:doc_viewer_app/domain/entities/markdown_style_preferences.dart';
import 'package:doc_viewer_app/infrastructure/services/preferences_service.dart';
import 'package:doc_viewer_app/infrastructure/services/annotation_service.dart';
import 'package:doc_viewer_app/presentation/theme/seez_theme.dart';
import 'package:doc_viewer_app/presentation/widgets/help_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'application/bloc/documentation_bloc.dart';
import 'application/bloc/documentation_event.dart';
import 'infrastructure/repositories/documentation_repository_impl.dart';
import 'infrastructure/datasources/filesystem_documentation_datasource.dart';
import 'presentation/screens/documentation_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/theme/app_theme.dart';

void main() {
  runApp(const FlorenceDocsApp());
}

class FlorenceDocsApp extends StatefulWidget {
  const FlorenceDocsApp({super.key});

  @override
  State<FlorenceDocsApp> createState() => _FlorenceDocsAppState();
}

class _FlorenceDocsAppState extends State<FlorenceDocsApp> {
  String? _selectedDocsPath;
  String _currentTheme = 'seez';
  MarkdownStylePreferences _markdownStyles = const MarkdownStylePreferences();
  final PreferencesService _prefsService = PreferencesService();
  static const MethodChannel _menuChannel = MethodChannel('com.florence.docs/menu');
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _setupMenuChannel();
  }

  void _setupMenuChannel() {
    _menuChannel.setMethodCallHandler((call) async {
      if (call.method == 'showHelp') {
        _showHelpDialog();
      }
    });
  }

  void _showHelpDialog() {
    final context = _navigatorKey.currentContext;
    if (context != null) {
      showDialog(
        context: context,
        builder: (context) => const HelpDialog(),
      );
    }
  }

  Future<void> _loadPreferences() async {
    final theme = await _prefsService.getTheme();
    final styles = await _prefsService.getMarkdownStyles();
    setState(() {
      _currentTheme = theme;
      _markdownStyles = styles;
    });
  }

  void _onDirectorySelected(String path) {
    setState(() {
      _selectedDocsPath = path;
    });
  }

  void _changeFolder() {
    setState(() {
      _selectedDocsPath = null;
    });
  }

  void _changeTheme(String theme) {
    setState(() {
      _currentTheme = theme;
    });
    _prefsService.setTheme(theme);
  }

  void _updateMarkdownStyles(MarkdownStylePreferences styles) {
    setState(() {
      _markdownStyles = styles;
    });
    _prefsService.setMarkdownStyles(styles);
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeData = _currentTheme == 'seez'
        ? SeezTheme.lightTheme
        : (_currentTheme == 'dark' ? AppTheme.darkTheme : AppTheme.lightTheme);

    return AnimatedTheme(
      data: currentThemeData,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Florence Documentation',
        debugShowCheckedModeBanner: false,
        theme: currentThemeData,
        darkTheme: AppTheme.darkTheme,
        themeMode: _currentTheme == 'dark' ? ThemeMode.dark : ThemeMode.light,
        home: _selectedDocsPath == null
            ? SplashScreen(onDirectorySelected: _onDirectorySelected)
            : BlocProvider(
                create: (_) => DocumentationBloc(
                  repository: DocumentationRepositoryImpl(
                    datasource: FilesystemDocumentationDatasource(
                      docsRootPath: _selectedDocsPath!,
                    ),
                  ),
                  annotationService: AnnotationService(
                    docsRootPath: _selectedDocsPath!,
                  ),
                )..add(const LoadFileTreeEvent()),
                child: DocumentationScreen(
                  onChangeFolder: _changeFolder,
                  currentTheme: _currentTheme,
                  onThemeChanged: _changeTheme,
                  markdownStyles: _markdownStyles,
                  onStylesChanged: _updateMarkdownStyles,
                  docsRootPath: _selectedDocsPath!,
                ),
              ),
      ),
    );
  }
}
