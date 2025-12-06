/// Route paths and names for the application
///
/// This file contains all route path constants and names used throughout
/// the application for type-safe navigation with go_router.
class RoutePaths {
  // Documentation routes
  static const splash = '/';
  static const documentation = '/docs';

  // Annotation routes (dialogs as named routes)
  static const annotationCreate = '/docs/annotation/create';
  static const annotationEdit = '/docs/annotation/edit';
  static const annotationView = '/docs/annotation/view';

  // Settings routes
  static const styleSettings = '/docs/settings/style';
  static const help = '/docs/help';

  // Git routes (placeholder for Phase 2)
  static const gitClone = '/docs/git/clone';
  static const gitCommit = '/docs/git/commit';
  static const gitHistory = '/docs/git/history';
  static const gitConflicts = '/docs/git/conflicts';
}

/// Route names for type-safe navigation
///
/// Use these constants with context.goNamed() for type-safe navigation.
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
