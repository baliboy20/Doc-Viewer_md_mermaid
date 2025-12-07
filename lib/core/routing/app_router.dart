import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Will be migrated to features/ in Week 2-3
import 'package:doc_viewer_app/features/documentation/presentation/screens/splash_screen.dart';
import 'package:doc_viewer_app/features/documentation/presentation/screens/documentation_screen.dart';

import 'package:doc_viewer_app/features/documentation/application/bloc/documentation_bloc.dart';
import 'package:doc_viewer_app/features/documentation/application/bloc/documentation_event.dart';
import 'package:doc_viewer_app/features/documentation/infrastructure/repositories/documentation_repository_impl.dart';
import 'package:doc_viewer_app/features/documentation/infrastructure/datasources/filesystem_documentation_datasource.dart';
import 'package:doc_viewer_app/features/annotations/infrastructure/services/annotation_service.dart';
import 'package:doc_viewer_app/features/documentation/domain/entities/markdown_style_preferences.dart';
import 'package:doc_viewer_app/core/utils/app_logger.dart';

// Git Integration
import 'package:doc_viewer_app/features/git/application/bloc/git_bloc.dart';
import 'package:doc_viewer_app/features/git/application/bloc/git_event.dart';
import 'package:doc_viewer_app/features/git/infrastructure/repositories/process_git_repository_impl.dart';
import 'package:doc_viewer_app/features/documentation/application/bloc/documentation_event.dart';

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
    AppLogger.info('Creating GoRouter', tag: 'AppRouter');

    return GoRouter(
      initialLocation: RoutePaths.splash,
      debugLogDiagnostics: true,

      // CRITICAL: Listen to selectedDocsPath to trigger redirect re-evaluation
      refreshListenable: selectedDocsPath,

      // Redirect logic based on state
      redirect: (context, state) {
        final hasDocsPath = selectedDocsPath.value != null;
        final isOnSplash = state.matchedLocation == RoutePaths.splash;

        AppLogger.info(
          'Router redirect evaluation',
          tag: 'AppRouter',
          data: 'hasDocsPath: $hasDocsPath, isOnSplash: $isOnSplash, currentLocation: ${state.matchedLocation}',
        );

        // If we have a docs path and we're on splash, go to documentation
        if (hasDocsPath && isOnSplash) {
          AppLogger.success(
            'Redirecting from splash to documentation',
            tag: 'AppRouter',
            data: selectedDocsPath.value,
          );
          return RoutePaths.documentation;
        }

        // If we don't have a docs path and we're not on splash, go to splash
        if (!hasDocsPath && !isOnSplash) {
          AppLogger.warning('No docs path, redirecting to splash', tag: 'AppRouter');
          return RoutePaths.splash;
        }

        AppLogger.debug('No redirect needed', tag: 'AppRouter');
        return null; // No redirect needed
      },

      routes: [
        // Splash / Directory Selection Screen
        GoRoute(
          path: RoutePaths.splash,
          name: RouteNames.splash,
          builder: (context, state) {
            AppLogger.info('Building SplashScreen route', tag: 'AppRouter');
            return SplashScreen(
              onDirectorySelected: (path) {
                AppLogger.success(
                  'Directory selected callback triggered',
                  tag: 'AppRouter',
                  data: path,
                );
                selectedDocsPath.value = path;
                AppLogger.info(
                  'selectedDocsPath.value updated',
                  tag: 'AppRouter',
                  data: 'New value: ${selectedDocsPath.value}',
                );
              },
            );
          },
        ),

        // Documentation Viewer (with nested routes for dialogs)
        GoRoute(
          path: RoutePaths.documentation,
          name: RouteNames.documentation,
          builder: (context, state) {
            AppLogger.info('Building DocumentationScreen route', tag: 'AppRouter');
            final docsPath = selectedDocsPath.value;

            // Safety check (should be redirected by redirect logic)
            if (docsPath == null) {
              AppLogger.warning(
                'DocumentationScreen builder called with null docsPath',
                tag: 'AppRouter',
              );
              return SplashScreen(
                onDirectorySelected: (path) {
                  selectedDocsPath.value = path;
                },
              );
            }

            AppLogger.success(
              'Creating DocumentationScreen',
              tag: 'AppRouter',
              data: 'docsPath: $docsPath',
            );

            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) {
                    AppLogger.info('Creating GitBloc', tag: 'AppRouter');
                    final gitBloc = GitBloc(
                      repository: ProcessGitRepositoryImpl(),
                    );

                    // Try to open the current docs folder as a Git repo
                    gitBloc.add(OpenRepositoryEvent(docsPath));

                    return gitBloc;
                  },
                ),
                BlocProvider(
                  create: (context) {
                    AppLogger.info('Creating DocumentationBloc', tag: 'AppRouter');
                    return DocumentationBloc(
                      repository: DocumentationRepositoryImpl(
                        datasource: FilesystemDocumentationDatasource(
                          docsRootPath: docsPath,
                        ),
                      ),
                      annotationService: AnnotationService(
                        docsRootPath: docsPath,
                      ),
                      onAnnotationChanged: () {
                        // Trigger Git status refresh when annotations change
                        AppLogger.info(
                          'Annotation changed, refreshing Git status',
                          tag: 'AppRouter',
                        );
                        context.read<GitBloc>().add(const GetRepositoryStatusEvent());
                      },
                    )..add(const LoadFileTreeEvent());
                  },
                ),
              ],
              child: DocumentationScreen(
                onChangeFolder: () {
                  AppLogger.info('Change folder requested', tag: 'AppRouter');
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
