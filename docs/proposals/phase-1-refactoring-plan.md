# Phase 1: Refactoring Implementation Plan

**Version:** 1.0
**Date:** 2025-12-06
**Status:** Ready to Execute

---

## Overview

This document outlines the detailed implementation plan for refactoring the Rome Doc Viewer codebase from layer-based to feature-based architecture, and implementing declarative routing with go_router.

**Timeline:** 4 weeks
**Goal:** Feature-based DDD structure + go_router for all navigation
**Success Criteria:** All existing functionality works, all tests pass, clean architecture established

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Week 1: Setup & Infrastructure](#week-1-setup--infrastructure)
3. [Week 2: Documentation Feature Migration](#week-2-documentation-feature-migration)
4. [Week 3: Annotations Feature Migration](#week-3-annotations-feature-migration)
5. [Week 4: Testing & Polish](#week-4-testing--polish)
6. [Rollback Plan](#rollback-plan)

---

## Prerequisites

### Required Packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  go_router: ^14.0.0
  flutter_secure_storage: ^9.0.0  # For future Git integration
```

### macOS Configuration (flutter_secure_storage)

**File:** `macos/Runner/DebugProfile.entitlements`

Add keychain access capability:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<!-- Existing entries... -->

	<!-- Add this for flutter_secure_storage -->
	<key>keychain-access-groups</key>
	<array/>
</dict>
</plist>
```

**File:** `macos/Runner/Release.entitlements`

Add the same keychain access capability:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<!-- Existing entries... -->

	<!-- Add this for flutter_secure_storage -->
	<key>keychain-access-groups</key>
	<array/>
</dict>
</plist>
```

### Git Branch Strategy

```bash
# Create feature branch for refactoring
git checkout -b refactor/feature-based-architecture

# All work happens on this branch
# Merge to main only after Week 4 testing passes
```

### Backup Current State

```bash
# Tag current state for easy rollback
git tag -a v1.5.0-pre-refactor -m "State before feature-based refactoring"
git push origin v1.5.0-pre-refactor
```

---

## Week 1: Setup & Infrastructure

**Goal:** Create new directory structure, add routing, move shared code to `core/`

### Day 1: Create Directory Structure

**Tasks:**

1. Create new directory structure:

```bash
mkdir -p lib/core/{theme,widgets,utils,routing,constants}
mkdir -p lib/features/documentation/{domain/{entities,repositories},infrastructure/{datasources,repositories},application/bloc,presentation/{screens,widgets}}
mkdir -p lib/features/annotations/{domain/{entities,repositories},infrastructure/{services,repositories},application/bloc,presentation/widgets}
mkdir -p lib/features/git/{domain/{entities,repositories},infrastructure/{repositories,services},application/bloc,presentation/{screens,widgets}}
```

2. Create placeholder README files in each feature:

```bash
# lib/features/documentation/README.md
echo "# Documentation Feature" > lib/features/documentation/README.md
echo "# Annotations Feature" > lib/features/annotations/README.md
echo "# Git Feature (Placeholder)" > lib/features/git/README.md
```

**Deliverable:** Clean directory structure ready for migration

---

### Day 2-3: Setup Routing Infrastructure

**Task 1:** Create routing files

**File:** `lib/core/routing/route_paths.dart`

```dart
/// Route paths and names for the application
class RoutePaths {
  // Documentation routes
  static const splash = '/';
  static const documentation = '/docs';

  // Annotation routes (dialogs as named routes)
  static const annotationCreate = '/docs/annotation/create';
  static const annotationEdit = '/docs/annotation/edit';
  static const annotationView = '/docs/annotation/view';

  // Settings routes
  static const styleSettings = '/settings/style';
  static const help = '/help';

  // Git routes (placeholder for Phase 2)
  static const gitClone = '/docs/git/clone';
  static const gitCommit = '/docs/git/commit';
  static const gitHistory = '/docs/git/history';
  static const gitConflicts = '/docs/git/conflicts';
}

/// Route names for type-safe navigation
class RouteNames {
  // Documentation
  static const splash = 'splash';
  static const documentation = 'documentation';

  // Annotations
  static const annotationCreate = 'annotation-create';
  static const annotationEdit = 'annotation-edit';
  static const annotationView = 'annotation-view';

  // Settings
  static const styleSettings = 'style-settings';
  static const help = 'help';

  // Git (placeholder)
  static const gitClone = 'git-clone';
  static const gitCommit = 'git-commit';
  static const gitHistory = 'git-history';
  static const gitConflicts = 'git-conflicts';
}
```

**File:** `lib/core/routing/app_router.dart`

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/documentation/presentation/screens/splash_screen.dart';
import '../../features/documentation/presentation/screens/documentation_screen.dart';
import '../../features/documentation/application/bloc/documentation_bloc.dart';
import '../../features/documentation/infrastructure/repositories/documentation_repository_impl.dart';
import '../../features/documentation/infrastructure/datasources/filesystem_documentation_datasource.dart';
import '../../features/annotations/infrastructure/services/annotation_service.dart';

import 'route_paths.dart';

/// Global router configuration
class AppRouter {
  static GoRouter createRouter({
    required ValueNotifier<String?> selectedDocsPath,
    required ValueNotifier<String> currentTheme,
    required ValueNotifier<MarkdownStylePreferences> markdownStyles,
  }) {
    return GoRouter(
      initialLocation: RoutePaths.splash,
      debugLogDiagnostics: true,

      // Redirect logic based on state
      redirect: (context, state) {
        final hasDocsPath = selectedDocsPath.value != null;
        final isOnSplash = state.matchedLocation == RoutePaths.splash;

        // If we have a docs path and we're on splash, go to documentation
        if (hasDocsPath && isOnSplash) {
          return RoutePaths.documentation;
        }

        // If we don't have a docs path and we're not on splash, go to splash
        if (!hasDocsPath && !isOnSplash) {
          return RoutePaths.splash;
        }

        return null; // No redirect needed
      },

      routes: [
        // Splash / Directory Selection
        GoRoute(
          path: RoutePaths.splash,
          name: RouteNames.splash,
          builder: (context, state) => SplashScreen(
            onDirectorySelected: (path) {
              selectedDocsPath.value = path;
            },
          ),
        ),

        // Documentation Viewer (with nested routes)
        GoRoute(
          path: RoutePaths.documentation,
          name: RouteNames.documentation,
          builder: (context, state) {
            final docsPath = selectedDocsPath.value;
            if (docsPath == null) {
              // Should be redirected by redirect logic, but safety check
              return SplashScreen(
                onDirectorySelected: (path) {
                  selectedDocsPath.value = path;
                },
              );
            }

            return BlocProvider(
              create: (_) => DocumentationBloc(
                repository: DocumentationRepositoryImpl(
                  datasource: FilesystemDocumentationDatasource(
                    docsRootPath: docsPath,
                  ),
                ),
                annotationService: AnnotationService(
                  docsRootPath: docsPath,
                ),
              )..add(const LoadFileTreeEvent()),
              child: DocumentationScreen(
                onChangeFolder: () {
                  selectedDocsPath.value = null;
                },
                currentTheme: currentTheme.value,
                onThemeChanged: (theme) {
                  currentTheme.value = theme;
                },
                markdownStyles: markdownStyles.value,
                onStylesChanged: (styles) {
                  markdownStyles.value = styles;
                },
                docsRootPath: docsPath,
              ),
            );
          },

          routes: [
            // Annotation routes (as dialogs)
            GoRoute(
              path: 'annotation/create',
              name: RouteNames.annotationCreate,
              pageBuilder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                return MaterialPage(
                  fullscreenDialog: true,
                  child: AnnotationDialog(
                    selectedText: extra?['selectedText'] as String? ?? '',
                    onSave: extra?['onSave'] as Function(String, String, List<String>)?,
                  ),
                );
              },
            ),

            // Style settings
            GoRoute(
              path: 'settings/style',
              name: RouteNames.styleSettings,
              pageBuilder: (context, state) {
                final extra = state.extra as Map<String, dynamic>?;
                return MaterialPage(
                  fullscreenDialog: true,
                  child: StyleSettingsDialog(
                    currentStyles: extra?['currentStyles'] as MarkdownStylePreferences,
                    onStylesChanged: extra?['onStylesChanged'] as Function(MarkdownStylePreferences),
                  ),
                );
              },
            ),

            // Help
            GoRoute(
              path: 'help',
              name: RouteNames.help,
              pageBuilder: (context, state) => const MaterialPage(
                fullscreenDialog: true,
                child: HelpDialog(),
              ),
            ),
          ],
        ),
      ],

      // Error handling
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Navigation Error',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(state.error?.toString() ?? 'Unknown error'),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(RoutePaths.splash),
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Task 2:** Update `main.dart` to use go_router

**File:** `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:doc_viewer_app/domain/entities/markdown_style_preferences.dart';
import 'package:doc_viewer_app/infrastructure/services/preferences_service.dart';
import 'package:doc_viewer_app/presentation/theme/seez_theme.dart';
import 'package:doc_viewer_app/presentation/theme/app_theme.dart';

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
  final ValueNotifier<String?> _selectedDocsPath = ValueNotifier(null);
  final ValueNotifier<String> _currentTheme = ValueNotifier('seez');
  final ValueNotifier<MarkdownStylePreferences> _markdownStyles =
      ValueNotifier(const MarkdownStylePreferences());

  final PreferencesService _prefsService = PreferencesService();
  static const MethodChannel _menuChannel = MethodChannel('com.florence.docs/menu');

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
        _router.goNamed(RouteNames.help);
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
```

**Deliverable:** Routing infrastructure ready, app compiles with go_router

---

### Day 4-5: Move Shared Code to `core/`

**Task 1:** Move theme files

```bash
# Move theme files to core
mv lib/presentation/theme/app_theme.dart lib/core/theme/
mv lib/presentation/theme/seez_theme.dart lib/core/theme/
```

Update imports in files that reference theme:
- Find all: `import 'package:doc_viewer_app/presentation/theme/`
- Replace with: `import 'package:doc_viewer_app/core/theme/`

**Task 2:** Create core utilities

**File:** `lib/core/constants/app_constants.dart`

```dart
/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Rome Doc Viewer';
  static const String appVersion = '1.5.0';
  static const String appCodeName = 'Martinique';

  // File Extensions
  static const List<String> supportedMarkdownExtensions = ['.md', '.markdown'];

  // Default Values
  static const double defaultBaseFontSize = 16.0;
  static const double defaultCodeFontSize = 14.0;
  static const double defaultHrThickness = 1.0;
  static const double defaultH1FontSize = 32.0;

  // Annotation Colors
  static const List<String> annotationColors = [
    'yellow',
    'blue',
    'green',
    'orange',
    'pink',
    'purple',
  ];

  // Preferences Keys
  static const String prefKeyTheme = 'theme';
  static const String prefKeyMarkdownStyles = 'markdown_styles';
  static const String prefKeyLastOpenedPath = 'last_opened_path';
}
```

**File:** `lib/core/utils/file_utils.dart`

```dart
import 'dart:io';
import '../constants/app_constants.dart';

/// Utility functions for file operations
class FileUtils {
  /// Checks if file is a supported markdown file
  static bool isMarkdownFile(String path) {
    return AppConstants.supportedMarkdownExtensions.any(
      (ext) => path.toLowerCase().endsWith(ext),
    );
  }

  /// Gets relative path from root
  static String getRelativePath(String rootPath, String filePath) {
    if (filePath.startsWith(rootPath)) {
      return filePath.substring(rootPath.length);
    }
    return filePath;
  }

  /// Checks if file exists
  static Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  /// Gets file name from path
  static String getFileName(String path) {
    return path.split('/').last;
  }
}
```

**Deliverable:** Core shared code organized in `lib/core/`

---

## Week 2: Documentation Feature Migration

**Goal:** Move all documentation-related code to `lib/features/documentation/`

### Day 1: Domain Layer Migration

**Task:** Move domain entities and repositories

```bash
# Move entities
mv lib/domain/entities/file_node.dart lib/features/documentation/domain/entities/
mv lib/domain/entities/markdown_style_preferences.dart lib/features/documentation/domain/entities/

# Move repository interface
mv lib/domain/repositories/documentation_repository.dart lib/features/documentation/domain/repositories/
```

**Update imports:** Replace all occurrences of:
- `package:doc_viewer_app/domain/entities/file_node.dart`
  → `package:doc_viewer_app/features/documentation/domain/entities/file_node.dart`
- Similar for other moved files

**Create barrel export (optional but recommended):**

**File:** `lib/features/documentation/domain/entities/entities.dart`

```dart
export 'file_node.dart';
export 'markdown_style_preferences.dart';
```

**Deliverable:** Domain layer migrated, all imports updated

---

### Day 2: Infrastructure Layer Migration

**Task:** Move infrastructure implementations

```bash
# Move datasource
mv lib/infrastructure/datasources/filesystem_documentation_datasource.dart \
   lib/features/documentation/infrastructure/datasources/

# Move repository implementation
mv lib/infrastructure/repositories/documentation_repository_impl.dart \
   lib/features/documentation/infrastructure/repositories/
```

**Update imports** in moved files to use new feature-based paths.

**Deliverable:** Infrastructure layer migrated

---

### Day 3: Application Layer Migration

**Task:** Move BLoC files

```bash
# Move BLoC files
mv lib/application/bloc/documentation_bloc.dart \
   lib/features/documentation/application/bloc/

mv lib/application/bloc/documentation_event.dart \
   lib/features/documentation/application/bloc/

mv lib/application/bloc/documentation_state.dart \
   lib/features/documentation/application/bloc/
```

**Update imports** in BLoC files.

**Deliverable:** Application layer migrated

---

### Day 4-5: Presentation Layer Migration

**Task:** Move screens and widgets

```bash
# Move screens
mv lib/presentation/screens/documentation_screen.dart \
   lib/features/documentation/presentation/screens/

mv lib/presentation/screens/splash_screen.dart \
   lib/features/documentation/presentation/screens/

# Move widgets
mv lib/presentation/widgets/content_area.dart \
   lib/features/documentation/presentation/widgets/

mv lib/presentation/widgets/file_tree.dart \
   lib/features/documentation/presentation/widgets/

mv lib/presentation/widgets/markdown_viewer.dart \
   lib/features/documentation/presentation/widgets/

mv lib/presentation/widgets/mermaid_diagram.dart \
   lib/features/documentation/presentation/widgets/

# Keep help_dialog and style_settings_dialog for now (shared widgets)
```

**Update all imports** in moved files.

**Test:** Run app and verify documentation viewing still works.

**Deliverable:** Documentation feature fully migrated and working

---

## Week 3: Annotations Feature Migration

**Goal:** Move all annotation-related code to `lib/features/annotations/`

### Day 1: Domain Layer Migration

**Task:** Move annotation entity

```bash
# Move entity
mv lib/domain/entities/annotation.dart \
   lib/features/annotations/domain/entities/
```

**Create repository interface:**

**File:** `lib/features/annotations/domain/repositories/annotation_repository.dart`

```dart
import '../entities/annotation.dart';

/// Repository interface for annotation operations
abstract class AnnotationRepository {
  Future<List<Annotation>> getAnnotationsForFile(String filePath);
  Future<void> saveAnnotation(Annotation annotation);
  Future<void> deleteAnnotation(String filePath, String annotationId);
  Future<void> updateAnnotation(Annotation annotation);
  Future<List<Annotation>> searchAnnotations(String query);
}
```

**Deliverable:** Annotation domain layer migrated

---

### Day 2: Infrastructure Layer Migration

**Task:** Move services and create repository implementation

```bash
# Move services
mv lib/infrastructure/services/annotation_service.dart \
   lib/features/annotations/infrastructure/services/

mv lib/infrastructure/services/annotation_parser.dart \
   lib/features/annotations/infrastructure/services/
```

**Create repository implementation:**

**File:** `lib/features/annotations/infrastructure/repositories/annotation_repository_impl.dart`

```dart
import '../../domain/entities/annotation.dart';
import '../../domain/repositories/annotation_repository.dart';
import '../services/annotation_service.dart';

/// Implementation of AnnotationRepository using AnnotationService
class AnnotationRepositoryImpl implements AnnotationRepository {
  final AnnotationService _service;

  AnnotationRepositoryImpl({required AnnotationService service})
      : _service = service;

  @override
  Future<List<Annotation>> getAnnotationsForFile(String filePath) {
    return _service.getAnnotationsForFile(filePath);
  }

  @override
  Future<void> saveAnnotation(Annotation annotation) {
    return _service.saveAnnotation(annotation);
  }

  @override
  Future<void> deleteAnnotation(String filePath, String annotationId) {
    return _service.deleteAnnotation(filePath, annotationId);
  }

  @override
  Future<void> updateAnnotation(Annotation annotation) {
    return _service.updateAnnotation(annotation);
  }

  @override
  Future<List<Annotation>> searchAnnotations(String query) {
    return _service.searchAnnotations(query);
  }
}
```

**Deliverable:** Annotation infrastructure layer migrated

---

### Day 3: Create Annotation BLoC

**File:** `lib/features/annotations/application/bloc/annotation_event.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/annotation.dart';

abstract class AnnotationEvent extends Equatable {
  const AnnotationEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnnotationsEvent extends AnnotationEvent {
  final String filePath;

  const LoadAnnotationsEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class AddAnnotationEvent extends AnnotationEvent {
  final String filePath;
  final String anchorText;
  final int? lineNumber;
  final String content;
  final String color;
  final List<String> tags;

  const AddAnnotationEvent({
    required this.filePath,
    required this.anchorText,
    required this.lineNumber,
    required this.content,
    this.color = 'yellow',
    this.tags = const [],
  });

  @override
  List<Object?> get props => [filePath, anchorText, lineNumber, content, color, tags];
}

class UpdateAnnotationEvent extends AnnotationEvent {
  final Annotation annotation;

  const UpdateAnnotationEvent(this.annotation);

  @override
  List<Object?> get props => [annotation];
}

class DeleteAnnotationEvent extends AnnotationEvent {
  final String filePath;
  final String annotationId;

  const DeleteAnnotationEvent(this.filePath, this.annotationId);

  @override
  List<Object?> get props => [filePath, annotationId];
}
```

**File:** `lib/features/annotations/application/bloc/annotation_state.dart`

```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/annotation.dart';

abstract class AnnotationState extends Equatable {
  const AnnotationState();

  @override
  List<Object?> get props => [];
}

class AnnotationInitial extends AnnotationState {}

class AnnotationLoading extends AnnotationState {}

class AnnotationLoaded extends AnnotationState {
  final List<Annotation> annotations;

  const AnnotationLoaded(this.annotations);

  @override
  List<Object?> get props => [annotations];
}

class AnnotationError extends AnnotationState {
  final String message;

  const AnnotationError(this.message);

  @override
  List<Object?> get props => [message];
}
```

**File:** `lib/features/annotations/application/bloc/annotation_bloc.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/annotation_repository.dart';
import '../../domain/entities/annotation.dart';
import 'annotation_event.dart';
import 'annotation_state.dart';

class AnnotationBloc extends Bloc<AnnotationEvent, AnnotationState> {
  final AnnotationRepository _repository;

  AnnotationBloc({required AnnotationRepository repository})
      : _repository = repository,
        super(AnnotationInitial()) {
    on<LoadAnnotationsEvent>(_onLoadAnnotations);
    on<AddAnnotationEvent>(_onAddAnnotation);
    on<UpdateAnnotationEvent>(_onUpdateAnnotation);
    on<DeleteAnnotationEvent>(_onDeleteAnnotation);
  }

  Future<void> _onLoadAnnotations(
    LoadAnnotationsEvent event,
    Emitter<AnnotationState> emit,
  ) async {
    emit(AnnotationLoading());
    try {
      final annotations = await _repository.getAnnotationsForFile(event.filePath);
      emit(AnnotationLoaded(annotations));
    } catch (e) {
      emit(AnnotationError(e.toString()));
    }
  }

  Future<void> _onAddAnnotation(
    AddAnnotationEvent event,
    Emitter<AnnotationState> emit,
  ) async {
    try {
      final annotation = Annotation(
        id: '', // Will be generated by service
        filePath: event.filePath,
        anchorText: event.anchorText,
        lineNumber: event.lineNumber,
        content: event.content,
        color: event.color,
        createdAt: DateTime.now(),
        tags: event.tags,
      );

      await _repository.saveAnnotation(annotation);

      // Reload annotations
      add(LoadAnnotationsEvent(event.filePath));
    } catch (e) {
      emit(AnnotationError(e.toString()));
    }
  }

  Future<void> _onUpdateAnnotation(
    UpdateAnnotationEvent event,
    Emitter<AnnotationState> emit,
  ) async {
    try {
      await _repository.updateAnnotation(event.annotation);

      // Reload annotations
      add(LoadAnnotationsEvent(event.annotation.filePath));
    } catch (e) {
      emit(AnnotationError(e.toString()));
    }
  }

  Future<void> _onDeleteAnnotation(
    DeleteAnnotationEvent event,
    Emitter<AnnotationState> emit,
  ) async {
    try {
      await _repository.deleteAnnotation(event.filePath, event.annotationId);

      // Reload annotations
      add(LoadAnnotationsEvent(event.filePath));
    } catch (e) {
      emit(AnnotationError(e.toString()));
    }
  }
}
```

**Deliverable:** Annotation BLoC created

---

### Day 4-5: Presentation Layer Migration

**Task:** Move annotation widgets

```bash
# Move widgets
mv lib/presentation/widgets/annotation_dialog.dart \
   lib/features/annotations/presentation/widgets/

mv lib/presentation/widgets/annotations_sidebar.dart \
   lib/features/annotations/presentation/widgets/

mv lib/presentation/widgets/positioned_annotation_gutter.dart \
   lib/features/annotations/presentation/widgets/
```

**Update widgets to use AnnotationBloc** where appropriate.

**Test:** Run app and verify annotations still work.

**Deliverable:** Annotations feature fully migrated and working

---

## Week 4: Testing & Polish

**Goal:** Comprehensive testing, cleanup, documentation

### Day 1-2: Testing

**Task 1:** Manual Testing Checklist

- [ ] App launches successfully
- [ ] Can select documentation folder
- [ ] File tree displays correctly
- [ ] Can open markdown files
- [ ] Markdown renders correctly (headers, code blocks, tables, etc.)
- [ ] Can create annotations
- [ ] Annotations display in sidebar
- [ ] Can click annotation badge to scroll to position
- [ ] Scroll-to-annotation works accurately
- [ ] Speech bubble tooltips show on hover
- [ ] Can edit annotations
- [ ] Can delete annotations
- [ ] Theme switching works (Seez, Light, Dark)
- [ ] Style settings dialog works
- [ ] Help dialog shows
- [ ] Change folder works
- [ ] All keyboard shortcuts work

**Task 2:** Automated Tests (if they exist)

```bash
# Run all tests
flutter test

# Fix any broken tests due to import path changes
```

**Task 3:** Performance Testing

- Test with large documentation folder (100+ files)
- Test with file containing many annotations (50+)
- Verify no memory leaks
- Check scroll performance

**Deliverable:** All tests pass, app is stable

---

### Day 3: Cleanup

**Task 1:** Remove empty directories

```bash
# Remove old empty directories
find lib -type d -empty -delete

# Should remove:
# - lib/domain/
# - lib/infrastructure/datasources/
# - lib/infrastructure/repositories/
# - lib/application/bloc/
# - lib/presentation/screens/
# (If they're now empty after migration)
```

**Task 2:** Update documentation

**File:** `lib/features/documentation/README.md`

```markdown
# Documentation Feature

This feature handles the core documentation viewing functionality.

## Structure

- **domain/** - Business entities and repository interfaces
  - `entities/file_node.dart` - File tree node representation
  - `entities/markdown_style_preferences.dart` - User style preferences
  - `repositories/documentation_repository.dart` - Repository interface

- **infrastructure/** - Implementation details
  - `datasources/filesystem_documentation_datasource.dart` - File system operations
  - `repositories/documentation_repository_impl.dart` - Repository implementation

- **application/** - Business logic
  - `bloc/documentation_bloc.dart` - State management for documentation

- **presentation/** - UI components
  - `screens/documentation_screen.dart` - Main documentation view
  - `screens/splash_screen.dart` - Folder selection screen
  - `widgets/content_area.dart` - Markdown content display
  - `widgets/file_tree.dart` - File tree navigation
  - `widgets/markdown_viewer.dart` - Markdown renderer

## Usage

```dart
// Load documentation
final bloc = DocumentationBloc(
  repository: DocumentationRepositoryImpl(
    datasource: FilesystemDocumentationDatasource(
      docsRootPath: '/path/to/docs',
    ),
  ),
);

bloc.add(LoadFileTreeEvent());
```
```

**Similar README files for:**
- `lib/features/annotations/README.md`
- `lib/core/README.md`

**Deliverable:** Clean codebase with documentation

---

### Day 4: Performance Optimization

**Task:** Check for any performance regressions

- Profile app startup time
- Check memory usage
- Verify smooth scrolling
- Check file tree rendering performance

**If issues found:** Optimize before moving to Day 5

**Deliverable:** App performs as well or better than before refactoring

---

### Day 5: Final Review & Merge

**Task 1:** Final code review

- Review all changed files
- Check for TODO comments
- Verify consistent code style
- Check for unused imports

**Task 2:** Update CHANGELOG

**File:** `CHANGELOG.md`

```markdown
## [1.6.0] - "Nassau" - 2025-12-XX

### Changed
- **BREAKING:** Refactored to feature-based architecture
  - Code organized by feature (documentation, annotations, git)
  - Improved separation of concerns
  - Better testability and maintainability
- Migrated to go_router for declarative navigation
  - Type-safe routing
  - Better deep linking support
  - Improved navigation state management
- Moved shared code to `lib/core/`
- Added macOS Keychain entitlements for secure storage

### Technical
- All imports updated to new feature-based paths
- Created feature READMEs for better documentation
- Added routing infrastructure for future features
- Prepared codebase for Git integration (Phase 2)

### Migration Notes
- Import paths have changed (e.g., `domain/entities/annotation.dart` → `features/annotations/domain/entities/annotation.dart`)
- If you have custom code that imports from this app, update import paths
```

**Task 3:** Update version in pubspec.yaml

```yaml
version: 1.6.0+0
```

**Task 4:** Update macOS version name

**File:** `macos/Runner/Configs/AppInfo.xcconfig`

```
VERSION_NAME = Nassau
```

**Task 5:** Create Git tag and merge

```bash
# Final test
flutter clean
flutter pub get
flutter run

# If all good:
git add .
git commit -m "Refactor: Migrate to feature-based architecture with go_router

- Organized code into features (documentation, annotations)
- Implemented declarative routing with go_router
- Moved shared code to lib/core/
- Updated all imports to new structure
- Added macOS Keychain entitlements
- Prepared for Git integration in Phase 2

BREAKING CHANGE: Import paths have changed to feature-based structure"

# Merge to main
git checkout main
git merge refactor/feature-based-architecture

# Tag the release
git tag -a v1.6.0 -m "Release v1.6.0 'Nassau' - Feature-based architecture"
git push origin main --tags
```

**Deliverable:** Clean, tested, merged refactoring ready for Phase 2

---

## Rollback Plan

If something goes wrong during refactoring:

### Option 1: Rollback to Tag

```bash
# Return to pre-refactor state
git checkout v1.5.0-pre-refactor

# Create new branch from there if needed
git checkout -b fix/rollback-refactor
```

### Option 2: Selective Rollback

If only one feature migration has issues:

```bash
# Rollback specific commits
git log --oneline  # Find the problematic commit
git revert <commit-hash>

# Or reset to specific commit (destructive)
git reset --hard <commit-hash>
```

### Option 3: Keep Refactoring Branch, Fix in Main

```bash
# If refactoring branch has issues, don't merge yet
# Fix issues in refactoring branch
# Continue development on main branch
# Merge refactoring when ready
```

---

## Success Metrics

### Must-Pass Criteria

- [ ] All existing features work (documentation viewing, annotations, themes, etc.)
- [ ] No runtime errors or crashes
- [ ] All tests pass (if automated tests exist)
- [ ] App launches and runs smoothly
- [ ] Performance is equal to or better than before
- [ ] Code is organized in feature-based structure
- [ ] Routing works for all screens/dialogs
- [ ] Documentation is updated

### Nice-to-Have

- [ ] Code coverage increased
- [ ] Build time improved
- [ ] App size reduced
- [ ] Startup time improved

---

## Post-Refactoring: Preparation for Phase 2 (Git Integration)

Once Phase 1 is complete, we're ready for Phase 2 (Git Integration).

**Phase 2 will be easier because:**

1. **Isolated Feature Directory:** All Git code goes in `lib/features/git/`
2. **Established Patterns:** Follow same structure as documentation/annotations features
3. **Routing Ready:** Just add Git routes to existing router
4. **No Import Conflicts:** Git feature won't affect other features

**Phase 2 Preview:**

```
lib/features/git/
├── domain/
│   ├── entities/
│   │   ├── git_commit.dart
│   │   ├── git_status.dart
│   │   └── git_credentials.dart
│   └── repositories/
│       └── git_repository.dart
├── infrastructure/
│   ├── repositories/
│   │   └── git2dart_repository.dart
│   └── services/
│       └── credential_storage.dart  # Uses flutter_secure_storage
├── application/
│   └── bloc/
│       ├── git_repository_bloc.dart
│       ├── git_sync_bloc.dart
│       └── git_commit_bloc.dart
└── presentation/
    ├── screens/
    │   ├── git_clone_screen.dart
    │   ├── git_commit_screen.dart
    │   └── git_conflict_resolution_screen.dart
    └── widgets/
        ├── git_status_indicator.dart
        └── commit_history_list.dart
```

This structure will be a **clean addition** with **no modifications** to existing features.

---

## Questions & Clarifications

Before starting Week 1, please confirm:

1. **Timeline:** Is 4 weeks acceptable, or do we need to compress/extend?
2. **Testing:** Do you have existing automated tests that need updating?
3. **Version Number:** OK with bumping to v1.6.0 "Nassau" for this refactoring?
4. **Deployment:** Should we deploy this as a release, or keep it internal until Git integration is added?
5. **Code Review:** Do you want to review at end of each week, or only at the end?

---

**Ready to start Week 1?** Let me know and I'll begin with Day 1: Create Directory Structure!
