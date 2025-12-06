# Florence Doc Viewer - Architecture Documentation

**Version:** 1.6.0 Nassau
**Last Updated:** 2025-12-06
**Status:** Production

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture Principles](#architecture-principles)
3. [Directory Structure](#directory-structure)
4. [Feature-Based Organization](#feature-based-organization)
5. [Core Shared Code](#core-shared-code)
6. [Routing System](#routing-system)
7. [State Management](#state-management)
8. [Cross-Feature Dependencies](#cross-feature-dependencies)
9. [Best Practices](#best-practices)
10. [Migration History](#migration-history)

---

## Overview

Florence Doc Viewer uses a **feature-based architecture** following **Domain-Driven Design (DDD)** principles and **Clean Architecture** patterns. The codebase is organized by business capability (features) rather than technical layers, making it easier to understand, maintain, and scale.

### Key Architectural Decisions

- **Feature-Based Structure**: Code organized by feature (documentation, annotations, git)
- **Clean Architecture**: Domain-centric with clear separation of concerns
- **BLoC Pattern**: Business Logic Components for state management
- **Declarative Routing**: go_router for type-safe, URL-based navigation
- **Repository Pattern**: Abstract data access through repository interfaces
- **Dependency Inversion**: Domain layer has no dependencies on other layers

---

## Architecture Principles

### 1. Feature Isolation
Each feature is self-contained with its own domain, infrastructure, application, and presentation layers. Features communicate through well-defined interfaces and events.

### 2. Dependency Rule
Dependencies flow inward toward the domain:
- **Presentation** depends on **Application** and **Domain**
- **Application** depends on **Domain**
- **Infrastructure** depends on **Domain**
- **Domain** depends on nothing (except Dart core)

### 3. Single Responsibility
Each layer has a clear, single responsibility:
- **Domain**: Business entities and rules
- **Infrastructure**: External concerns (file I/O, parsing, storage)
- **Application**: Use cases and state management
- **Presentation**: UI and user interaction

### 4. Interface Segregation
Use repository interfaces to decouple business logic from implementation details. Infrastructure provides concrete implementations.

---

## Directory Structure

```
lib/
├── core/                           # Shared code across all features
│   ├── constants/                  # App-wide constants
│   │   └── app_constants.dart
│   ├── routing/                    # Routing configuration
│   │   ├── app_router.dart        # GoRouter setup
│   │   └── route_paths.dart       # Route constants
│   ├── theme/                      # App themes
│   │   ├── app_theme.dart
│   │   └── seez_theme.dart
│   ├── utils/                      # Shared utilities
│   │   ├── app_logger.dart
│   │   ├── file_utils.dart
│   │   └── preferences_service.dart
│   ├── widgets/                    # Shared widgets
│   │   └── help_dialog.dart
│   └── README.md
│
├── features/                       # Feature modules
│   ├── documentation/              # Documentation viewer feature
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── file_node.dart
│   │   │   │   └── markdown_style_preferences.dart
│   │   │   └── repositories/
│   │   │       └── documentation_repository.dart
│   │   ├── infrastructure/
│   │   │   ├── datasources/
│   │   │   │   └── filesystem_documentation_datasource.dart
│   │   │   ├── repositories/
│   │   │   │   └── filesystem_documentation_repository_impl.dart
│   │   │   └── services/
│   │   │       └── markdown_element_indexer.dart
│   │   ├── application/
│   │   │   └── bloc/
│   │   │       ├── documentation_bloc.dart
│   │   │       ├── documentation_event.dart
│   │   │       └── documentation_state.dart
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── documentation_screen.dart
│   │   │   │   └── splash_screen.dart
│   │   │   └── widgets/
│   │   │       ├── content_area.dart
│   │   │       ├── markdown_viewer.dart
│   │   │       ├── mermaid_*.dart
│   │   │       ├── sidebar_*.dart
│   │   │       └── style_settings_dialog.dart
│   │   └── README.md
│   │
│   ├── annotations/                # Sticky notes feature
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── annotation.dart
│   │   │   └── repositories/
│   │   │       └── annotation_repository.dart
│   │   ├── infrastructure/
│   │   │   ├── repositories/
│   │   │   │   └── annotation_repository_impl.dart
│   │   │   └── services/
│   │   │       ├── annotation_parser.dart
│   │   │       └── annotation_service.dart
│   │   ├── application/
│   │   │   └── bloc/
│   │   │       ├── annotation_bloc.dart
│   │   │       ├── annotation_event.dart
│   │   │       └── annotation_state.dart
│   │   ├── presentation/
│   │   │   └── widgets/
│   │   │       ├── annotation_dialog.dart
│   │   │       ├── annotation_gutter.dart
│   │   │       ├── annotation_indicator.dart
│   │   │       ├── annotations_sidebar.dart
│   │   │       └── positioned_annotation_gutter.dart
│   │   └── README.md
│   │
│   └── git/                        # Git integration (Phase 2 - placeholder)
│       └── README.md
│
└── main.dart                       # App entry point
```

---

## Feature-Based Organization

Each feature follows the same four-layer structure:

### Domain Layer (`domain/`)
**Purpose**: Core business logic and entities
**Contains**:
- **Entities**: Pure business objects (e.g., `Annotation`, `FileNode`)
- **Repository Interfaces**: Abstract contracts for data access

**Rules**:
- No dependencies on other layers
- Only pure Dart code (no Flutter dependencies)
- Immutable entities using `@immutable` or `const`
- Repository interfaces define what, not how

**Example**:
```dart
// domain/entities/annotation.dart
@immutable
class Annotation {
  final String id;
  final String filePath;
  final String content;
  // ...
}

// domain/repositories/annotation_repository.dart
abstract class AnnotationRepository {
  Future<List<Annotation>> getAnnotationsForFile(String filePath);
  Future<void> saveAnnotation(Annotation annotation);
}
```

### Infrastructure Layer (`infrastructure/`)
**Purpose**: External concerns and implementations
**Contains**:
- **Datasources**: File I/O, API calls, database access
- **Services**: Parsing, serialization, external integrations
- **Repository Implementations**: Concrete implementations of domain interfaces

**Rules**:
- Depends on domain layer (implements repository interfaces)
- Handles all I/O and external communication
- Contains platform-specific code
- No direct dependency on presentation layer

**Example**:
```dart
// infrastructure/repositories/annotation_repository_impl.dart
class AnnotationRepositoryImpl implements AnnotationRepository {
  final AnnotationService _service;

  @override
  Future<List<Annotation>> getAnnotationsForFile(String filePath) {
    return _service.getAnnotationsForFile(filePath);
  }
}
```

### Application Layer (`application/`)
**Purpose**: Use cases and state management
**Contains**:
- **BLoC**: Business Logic Components
- **Events**: User actions and triggers
- **States**: UI state representations

**Rules**:
- Depends on domain layer
- Orchestrates use cases
- No UI code or widgets
- Pure business logic orchestration

**Example**:
```dart
// application/bloc/annotation_bloc.dart
class AnnotationBloc extends Bloc<AnnotationEvent, AnnotationState> {
  final AnnotationRepository _repository;

  Future<void> _onAddAnnotation(
    AddAnnotationEvent event,
    Emitter<AnnotationState> emit,
  ) async {
    // Business logic for adding annotation
    final annotation = Annotation(...);
    await _repository.saveAnnotation(annotation);
    emit(AnnotationOperationSuccess(...));
  }
}
```

### Presentation Layer (`presentation/`)
**Purpose**: UI and user interaction
**Contains**:
- **Screens**: Full-page views
- **Widgets**: Reusable UI components
- **Dialogs**: Modal interactions

**Rules**:
- Depends on application and domain layers
- Contains Flutter widgets only
- BLoC consumers and providers live here
- No business logic (delegate to BLoC)

**Example**:
```dart
// presentation/screens/documentation_screen.dart
class DocumentationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentationBloc, DocumentationState>(
      builder: (context, state) {
        // UI rendering based on state
      },
    );
  }
}
```

---

## Core Shared Code

The `lib/core/` directory contains code shared across multiple features:

### Constants (`core/constants/`)
Application-wide constants that don't belong to a specific feature:
- App name, version, code names
- Supported file extensions
- Default values and configurations

**Example**: `app_constants.dart`
```dart
class AppConstants {
  static const String appName = 'Rome Doc Viewer';
  static const String appVersion = '1.6.0';
  static const String appCodeName = 'Nassau';
  static const List<String> supportedMarkdownExtensions = ['.md', '.markdown'];
}
```

### Routing (`core/routing/`)
Centralized routing configuration using go_router:
- **route_paths.dart**: Route path and name constants
- **app_router.dart**: GoRouter configuration and redirect logic

### Theme (`core/theme/`)
App-wide themes:
- **app_theme.dart**: Light/dark themes
- **seez_theme.dart**: Custom Seez theme

### Utils (`core/utils/`)
Shared utility functions:
- **app_logger.dart**: Centralized logging
- **file_utils.dart**: File operation helpers
- **preferences_service.dart**: User preferences persistence

### Widgets (`core/widgets/`)
Widgets used across multiple features:
- **help_dialog.dart**: App help dialog (triggered from menu)

**When to use `core/` vs feature-specific**:
- Use `core/` when 3+ features need the same code
- Use `core/` for app-level concerns (routing, theme, logging)
- Keep feature-specific code in features, even if only used once

---

## Routing System

### go_router Architecture

Florence uses **go_router** for declarative, type-safe routing. All navigation is URL-based and supports deep linking.

### Route Configuration

**File**: `lib/core/routing/route_paths.dart`
```dart
class RoutePaths {
  static const splash = '/';
  static const documentation = '/docs';
  static const annotationCreate = '/docs/annotation/create';
}

class RouteNames {
  static const splash = 'splash';
  static const documentation = 'documentation';
  static const annotationCreate = 'annotation-create';
}
```

**File**: `lib/core/routing/app_router.dart`
```dart
class AppRouter {
  static GoRouter createRouter({
    required ValueNotifier<String?> selectedDocsPath,
    required ValueNotifier<String> currentTheme,
    required ValueNotifier<MarkdownStylePreferences> markdownStyles,
  }) {
    return GoRouter(
      initialLocation: RoutePaths.splash,
      redirect: (context, state) {
        // State-based routing logic
      },
      routes: [
        GoRoute(
          path: RoutePaths.splash,
          name: RouteNames.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        // More routes...
      ],
    );
  }
}
```

### State Management with ValueNotifiers

App-level state is managed using Flutter's `ValueNotifier`:
- `_selectedDocsPath`: Currently opened documentation folder
- `_currentTheme`: Active theme (seez/light/dark)
- `_markdownStyles`: User markdown style preferences

These notifiers are passed to the router and can trigger navigation based on state changes.

### Navigation Examples

```dart
// Navigate to documentation screen
context.goNamed(RouteNames.documentation);

// Navigate with parameters
context.goNamed(
  RouteNames.annotationCreate,
  pathParameters: {'filePath': '/path/to/file.md'},
);

// Show dialog (still uses traditional approach)
showDialog(
  context: context,
  builder: (context) => AnnotationDialog(...),
);
```

---

## State Management

### BLoC Pattern

Florence uses the **BLoC (Business Logic Component)** pattern via the `flutter_bloc` package.

### BLoC Structure

Each feature has its own BLoC with three files:

1. **Events** (`*_event.dart`): User actions and triggers
2. **States** (`*_state.dart`): UI state representations
3. **BLoC** (`*_bloc.dart`): Event handlers and state transitions

### Example: Annotation BLoC

**Events**:
```dart
abstract class AnnotationEvent extends Equatable {}

class LoadAnnotationsEvent extends AnnotationEvent {
  final String filePath;
  const LoadAnnotationsEvent(this.filePath);
}

class AddAnnotationEvent extends AnnotationEvent {
  final String filePath;
  final String content;
  // ...
}
```

**States**:
```dart
abstract class AnnotationState extends Equatable {}

class AnnotationInitial extends AnnotationState {}
class AnnotationLoading extends AnnotationState {}
class AnnotationLoaded extends AnnotationState {
  final List<Annotation> annotations;
  const AnnotationLoaded(this.annotations);
}
class AnnotationError extends AnnotationState {
  final String message;
  const AnnotationError(this.message);
}
```

**BLoC**:
```dart
class AnnotationBloc extends Bloc<AnnotationEvent, AnnotationState> {
  final AnnotationRepository _repository;

  AnnotationBloc({required AnnotationRepository repository})
      : _repository = repository,
        super(AnnotationInitial()) {
    on<LoadAnnotationsEvent>(_onLoadAnnotations);
    on<AddAnnotationEvent>(_onAddAnnotation);
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
}
```

### BLoC Provider Setup

BLoCs are provided at the appropriate level in the widget tree:

```dart
// Feature-level provider
BlocProvider<AnnotationBloc>(
  create: (context) => AnnotationBloc(
    repository: AnnotationRepositoryImpl(
      service: AnnotationService(),
    ),
  ),
  child: AnnotationsSidebar(),
)

// Feature-level consumer
BlocBuilder<AnnotationBloc, AnnotationState>(
  builder: (context, state) {
    if (state is AnnotationLoading) {
      return CircularProgressIndicator();
    } else if (state is AnnotationLoaded) {
      return AnnotationList(annotations: state.annotations);
    }
    // ...
  },
)
```

---

## Cross-Feature Dependencies

### Import Strategy

**Within a Feature** (same feature): Use **relative imports**
```dart
// In lib/features/annotations/infrastructure/services/annotation_service.dart
import '../../domain/entities/annotation.dart';
import '../../domain/repositories/annotation_repository.dart';
import 'annotation_parser.dart';
```

**Between Features** (cross-feature): Use **package imports**
```dart
// In lib/features/annotations/infrastructure/services/annotation_parser.dart
import 'package:doc_viewer_app/features/documentation/infrastructure/services/markdown_element_indexer.dart';
```

**From Core**: Always use **package imports**
```dart
// From any feature
import 'package:doc_viewer_app/core/utils/app_logger.dart';
import 'package:doc_viewer_app/core/constants/app_constants.dart';
```

### Cross-Feature Communication

Features should communicate through:

1. **Shared Core Services**: Place truly shared logic in `core/`
2. **Events/Callbacks**: Pass callbacks down from parent widgets
3. **Repository Interfaces**: Access other features' data through clean interfaces
4. **Direct Imports (Limited)**: Only for infrastructure services that are truly shared (e.g., `markdown_element_indexer.dart`)

### When to Share Code

**Create shared code in `core/` when**:
- 3+ features need the same functionality
- Code is truly domain-agnostic (logging, utils, theme)
- App-level concerns (routing, preferences)

**Keep code feature-specific when**:
- Only 1-2 features need it
- Code is tightly coupled to a feature's domain
- Even if another feature imports it (acceptable with package imports)

---

## Best Practices

### 1. Feature Independence
- Each feature should be as self-contained as possible
- Minimize cross-feature dependencies
- Use repository interfaces to decouple features

### 2. Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `SCREAMING_SNAKE_CASE` or `camelCase` for class constants
- **Private**: prefix with `_`

### 3. File Organization
- Keep files small (< 300 lines)
- One class per file (except small helper classes)
- Group related files in subdirectories

### 4. Import Organization
```dart
// 1. Dart SDK imports
import 'dart:async';
import 'dart:io';

// 2. Flutter framework imports
import 'package:flutter/material.dart';

// 3. Package imports (alphabetical)
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// 4. Project imports - relative for same feature
import '../../domain/entities/annotation.dart';

// 5. Project imports - package for cross-feature/core
import 'package:doc_viewer_app/core/utils/app_logger.dart';
```

### 5. BLoC Best Practices
- One BLoC per feature (can have multiple if feature is large)
- Events should be past tense or imperative (e.g., `LoadAnnotationsEvent`, `AddAnnotationEvent`)
- States should describe the UI state (e.g., `AnnotationLoading`, `AnnotationLoaded`)
- Always handle errors with error states
- Use `Equatable` for events and states

### 6. Repository Pattern
- Define interfaces in domain layer
- Implement in infrastructure layer
- Inject through BLoC constructor
- Makes testing easier (can mock repositories)

### 7. Testing Strategy
- **Unit Tests**: Test domain entities and business logic
- **Widget Tests**: Test presentation layer components
- **Integration Tests**: Test feature workflows end-to-end
- **BLoC Tests**: Test event → state transitions using `bloc_test` package

### 8. Code Documentation
- Document public APIs with `///` comments
- Explain "why", not "what"
- Keep README.md updated in each feature directory
- Update this ARCHITECTURE.md when making structural changes

---

## Migration History

### Phase 1: Feature-Based Refactoring (v1.6.0 Nassau)

**Date**: December 2025
**Status**: ✅ Completed

#### Changes Made

1. **Week 1: Setup & Infrastructure**
   - Added `go_router` ^14.0.0 and `flutter_secure_storage` ^9.0.0
   - Configured macOS Keychain entitlements
   - Created feature-based directory structure
   - Implemented go_router with ValueNotifier state management
   - Created `lib/core/` with routing, theme, utils, constants, and widgets

2. **Week 2: Documentation Feature Migration**
   - Moved all documentation-related code to `lib/features/documentation/`
   - Organized into domain/infrastructure/application/presentation layers
   - Updated all imports to use package format
   - Created feature README.md

3. **Week 3: Annotations Feature Migration**
   - Moved all annotation-related code to `lib/features/annotations/`
   - Created `AnnotationRepository` interface and implementation
   - Implemented complete `AnnotationBloc` with events and states
   - Organized into domain/infrastructure/application/presentation layers
   - Moved `markdown_element_indexer.dart` to documentation feature (shared infrastructure)

4. **Week 4: Testing & Polish**
   - Fixed all compilation errors
   - Updated imports for cross-feature dependencies
   - Verified app compiles successfully
   - Removed old layer-based directory structure
   - Created comprehensive architecture documentation

#### Before vs After

**Before (Layer-Based)**:
```
lib/
├── domain/
├── infrastructure/
├── application/
├── presentation/
└── main.dart
```

**After (Feature-Based)**:
```
lib/
├── core/
├── features/
│   ├── documentation/
│   ├── annotations/
│   └── git/
└── main.dart
```

#### Benefits Achieved

1. ✅ **Better Organization**: Code grouped by feature, easier to find and understand
2. ✅ **Scalability**: Easy to add new features without touching existing code
3. ✅ **Team Collaboration**: Different teams can work on different features independently
4. ✅ **Testing**: Easier to test features in isolation
5. ✅ **Maintainability**: Changes to one feature don't affect others
6. ✅ **Onboarding**: New developers can understand one feature at a time

### Future Phases

**Phase 2: Git Integration** (Planned)
- Implement full Git integration feature in `lib/features/git/`
- Version control operations
- Commit history viewing
- Diff visualization
- Branch management

---

## Resources

### Documentation
- [Main README](../README.md)
- [Phase 1 Refactoring Plan](proposals/phase-1-refactoring-plan.md)
- [Git Integration Proposal](proposals/git-integration-proposal.md)
- [Implementation Roadmap](proposals/IMPLEMENTATION_ROADMAP.md)

### Package Documentation
- [go_router](https://pub.dev/packages/go_router) - Declarative routing
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) - BLoC pattern implementation
- [equatable](https://pub.dev/packages/equatable) - Value equality
- [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) - Secure credential storage

### External References
- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)
- [Flutter BLoC Pattern](https://bloclibrary.dev)
- [Feature-First Architecture in Flutter](https://codewithandrea.com/articles/flutter-project-structure/)

---

**Maintained by**: Will (Florence Development Team)
**Last Review**: 2025-12-06
**Next Review**: 2026-01-06 (or before Phase 2 implementation)
