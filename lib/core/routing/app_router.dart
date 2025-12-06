import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Will be migrated to features/ in Week 2-3
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/documentation_screen.dart';

import 'package:doc_viewer_app/features/documentation/application/bloc/documentation_bloc.dart';
import 'package:doc_viewer_app/features/documentation/application/bloc/documentation_event.dart';
import 'package:doc_viewer_app/features/documentation/infrastructure/repositories/documentation_repository_impl.dart';
import 'package:doc_viewer_app/features/documentation/infrastructure/datasources/filesystem_documentation_datasource.dart';
import '../../infrastructure/services/annotation_service.dart';
import 'package:doc_viewer_app/features/documentation/domain/entities/markdown_style_preferences.dart';

import 'route_paths.dart';

/// Global router configuration for the application
///
/// This router manages all navigation using go_router's declarative routing.
/// It maintains app state (docs path, theme, styles) using ValueNotifiers.
class AppRouter {
  /// Creates the GoRouter instance with app state
  ///
  /// Parameters:
  /// - [selectedDocsPath]: Notifier for currently selected documentation folder
  /// - [currentTheme]: Notifier for current theme (seez, light, dark)
  /// - [markdownStyles]: Notifier for markdown style preferences
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
        // Splash / Directory Selection Screen
        GoRoute(
          path: RoutePaths.splash,
          name: RouteNames.splash,
          builder: (context, state) => SplashScreen(
            onDirectorySelected: (path) {
              selectedDocsPath.value = path;
            },
          ),
        ),

        // Documentation Viewer (with nested routes for dialogs)
        GoRoute(
          path: RoutePaths.documentation,
          name: RouteNames.documentation,
          builder: (context, state) {
            final docsPath = selectedDocsPath.value;

            // Safety check (should be redirected by redirect logic)
            if (docsPath == null) {
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

          // Note: Dialogs (annotations, settings, help) will be migrated
          // to routing in Week 2-3 during feature migration.
          // For now, they continue to use showDialog() from widgets.
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  state.error?.toString() ?? 'Unknown error',
                  textAlign: TextAlign.center,
                ),
              ),
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
