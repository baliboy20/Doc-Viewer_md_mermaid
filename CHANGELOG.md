# Changelog

All notable changes to DocViewer will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.1] - 2025-12-10

### Fixed
- **Theme Switcher Reactivity**: Theme changes now apply immediately without requiring view navigation
  - Wrapped DocumentationScreen with ValueListenableBuilder for reactive theme/style updates
  - Added theme and markdown style notifiers to router's refreshListenable
  - Sidebar and document content now update instantly when theme is changed

## [2.0.0 "Oman"] - 2025-12-07

### Added
- **Discard Changes Functionality**: Full implementation for discarding uncommitted changes
  - New `discardChanges()` method in GitRepository interface
  - Process-based implementation using `git restore .` and `git clean -fd`
  - Added `DiscardChangesEvent` and `DiscardSuccess` state to GitBloc
  - Updated Git sidebar panel to trigger discard operation
  - Confirmation dialog to prevent accidental data loss
- **Automatic Git Status Refresh**: Git panel now automatically updates after annotation operations
  - Added `onAnnotationChanged` callback to DocumentationBloc
  - Callback triggers `GetRepositoryStatusEvent` on GitBloc
  - Status refreshes immediately after add/update/delete annotation operations
  - No manual refresh button click required

### Changed
- **Code Signing Configuration**: Updated for local DMG builds without certificates
  - Modified `Release.entitlements` to disable app sandboxing and remove keychain requirements
  - Added ad-hoc signing configuration to `Release.xcconfig` (CODE_SIGN_IDENTITY = -, CODE_SIGN_STYLE = Manual)
  - Updated `package_dmg.sh` to include explicit ad-hoc signing step
  - DMG packages can now be created for local distribution without developer certificates

### Fixed
- **Git Commit Message Validation**: Resolved mismatch between UI and repository requirements
  - Updated commit dialog to require minimum 10 characters (was 3)
  - Now matches Git repository validation requirement
  - Prevents commit failures due to validation discrepancy
- **BLoC Provider Ordering**: Ensured GitBloc is created before DocumentationBloc
  - Allows DocumentationBloc callback to access GitBloc via BuildContext
  - Fixes potential null reference issues during annotation operations

### Technical Implementation
- Added `VoidCallback` import to DocumentationBloc for callback support
- Implemented two-step discard process: restore tracked files, then clean untracked files
- Enhanced error handling with AppLogger integration in discard operations
- Updated Git sidebar to show operation-in-progress feedback

## [1.6.0 "Nassau"] - 2025-12-06

### Major Architectural Refactoring - Phase 1

This release represents a complete architectural transformation from layer-based to feature-based organization, establishing a foundation for future development.

### Added
- **Feature-Based Architecture**: Complete restructuring to Domain-Driven Design (DDD)
  - `lib/features/documentation/` - Documentation viewer feature (complete)
  - `lib/features/annotations/` - Sticky notes feature (complete)
  - `lib/features/git/` - Git integration feature (placeholder for Phase 2)
  - Each feature organized into domain/infrastructure/application/presentation layers
- **Declarative Routing System**: Implemented go_router for type-safe navigation
  - `lib/core/routing/app_router.dart` - Centralized router configuration
  - `lib/core/routing/route_paths.dart` - Route path and name constants
  - State-based routing with ValueNotifiers for app-level state
  - Support for deep linking and URL-based navigation
- **Core Shared Infrastructure**: Organized shared code in `lib/core/`
  - `core/constants/` - App-wide constants (app name, version, supported extensions)
  - `core/theme/` - Theme configurations (Seez, light, dark themes)
  - `core/utils/` - Shared utilities (logging, file operations, preferences)
  - `core/widgets/` - Shared widgets (help dialog)
  - `core/routing/` - Routing configuration
- **Repository Pattern**: Clean separation of concerns
  - `DocumentationRepository` interface and `FilesystemDocumentationRepositoryImpl`
  - `AnnotationRepository` interface and `AnnotationRepositoryImpl`
  - Infrastructure layer implements domain interfaces
- **Complete BLoC Implementation for Annotations**
  - `AnnotationBloc` with full event/state management
  - `AnnotationEvent` types: Load, Add, Update, Delete, Search
  - `AnnotationState` types: Initial, Loading, Loaded, Success, Error
  - Proper error handling and state transitions
- **Comprehensive Documentation**
  - `docs/ARCHITECTURE.md` - Complete architectural guide (40+ pages)
  - Updated `README.md` with project overview and usage guide
  - Feature-specific READMEs in each feature directory
  - Architecture principles, best practices, and migration history

### Changed
- **Project Structure**: Migrated from layer-based to feature-based organization
  - **Before**: `lib/{domain,infrastructure,application,presentation}/`
  - **After**: `lib/{core,features/{documentation,annotations,git}}/`
  - Removed old layer-based directories after successful migration
- **Main App Entry Point**: Updated to use go_router
  - Converted from `MaterialApp` to `MaterialApp.router`
  - Implemented ValueNotifiers for reactive state management
  - Integrated router configuration with app state
- **Import Strategy**: Established clear import conventions
  - Within feature: relative imports (e.g., `'../../domain/entities/annotation.dart'`)
  - Cross-feature: package imports (e.g., `'package:doc_viewer_app/features/..'`)
  - Core imports: always package imports
  - Ensures clear dependency flow and better maintainability
- **Feature Organization**: All code grouped by business capability
  - Documentation feature: File tree, markdown rendering, style preferences
  - Annotations feature: Sticky notes, gutter, sidebar, dialog
  - Clear feature boundaries with minimal coupling
- **Dependency Management**: Added packages for Phase 1 and Phase 2
  - `go_router` ^14.0.0 - Declarative routing
  - `flutter_secure_storage` ^9.0.0 - Keychain integration (Phase 2 prep)
- **macOS Configuration**: Added Keychain entitlements
  - Updated `DebugProfile.entitlements` and `Release.entitlements`
  - Added `keychain-access-groups` capability for secure credential storage

### Fixed
- All imports updated to use correct package paths after migration
- Cross-feature dependencies properly resolved using package imports
- Compilation errors resolved (markdown_element_indexer import in annotation_parser)
- Unused imports removed (annotation_gutter in content_area)
- Test file updated to reference correct app class (FlorenceDocsApp)

### Technical Implementation
- **Week 1: Setup & Infrastructure**
  - Created feature-based directory structure
  - Implemented go_router with state management
  - Established core shared code organization
  - Moved theme and utility files to core
- **Week 2: Documentation Feature Migration**
  - Migrated all documentation code to feature directory
  - Organized into DDD layers (domain → infrastructure → application → presentation)
  - Updated 40+ import statements to use package format
  - Created feature README.md
- **Week 3: Annotations Feature Migration**
  - Migrated all annotation code to feature directory
  - Created repository interface and implementation
  - Implemented complete AnnotationBloc with events/states
  - Moved markdown_element_indexer to documentation feature (shared infrastructure)
  - Updated all cross-feature dependencies
- **Week 4: Testing & Polish**
  - Ran `flutter clean && flutter pub get`
  - Fixed compilation errors and import issues
  - Verified successful compilation (0 errors, 37 info/warnings)
  - Created comprehensive architecture documentation
  - Updated main README with project overview

### Architecture Benefits
- **Scalability**: Easy to add new features without touching existing code
- **Maintainability**: Features are self-contained and independently testable
- **Team Collaboration**: Different teams can work on different features
- **Code Organization**: Business logic grouped by capability, not technical layer
- **Dependency Clarity**: Clear import strategy prevents circular dependencies
- **Testing**: Features can be tested in isolation
- **Onboarding**: New developers can understand one feature at a time

### Migration Path
- All existing functionality preserved - no breaking changes
- Feature parity with v1.5.0 maintained
- Clean architecture establishes foundation for Phase 2 (Git integration)
- Comprehensive documentation for future development

### Dependencies Added
```yaml
dependencies:
  go_router: ^14.0.0              # Declarative routing
  flutter_secure_storage: ^9.0.0  # Secure credential storage (Phase 2)
```

### Files Changed
- **Created**: 40+ new files in feature-based structure
- **Updated**: 50+ files with new import paths
- **Moved**: All domain, infrastructure, application, presentation code
- **Removed**: Old layer-based directories (lib/domain, lib/infrastructure, etc.)

### Documentation
- `docs/ARCHITECTURE.md` - Complete architectural reference
- `README.md` - Updated with project overview and usage
- `docs/proposals/phase-1-refactoring-plan.md` - Implementation plan
- Feature READMEs in each feature directory

### Next Steps
**Phase 2: Git Integration** (Planned for v1.7.0)
- Version control operations
- Commit history viewing
- Diff visualization
- Branch management

---

## [1.5.0 "Martinique"] - 2025-12-06

### Added
- **Visual Annotation Markers**: Annotation anchor points now display with visible 📌 emoji icons
  - Emoji markers embedded directly in markdown links: `[📌](#annotation-marker-xxx)`
  - Eliminates need for custom rendering - uses native markdown link rendering
  - Icons appear inline at exact annotation positions
  - Backwards compatible with old invisible marker format
- **Custom Speech Bubble Tooltips**: Beautiful custom tooltips for annotation badges
  - Speech bubble shape with triangular stem pointing to badge
  - Background color matches badge color (yellow, red, blue, green, orange, purple)
  - Rounded corners with soft shadow for depth
  - White text with Inter font for readability
  - 300ms hover delay, max 3 lines with ellipsis
  - Positioned to the right of badges using Overlay system

### Changed
- **Improved Scroll-to-Annotation Accuracy**: Two-phase positioning for precise scrolling
  - Phase 1: Scroll to exact marker position at viewport top
  - Phase 2: Adjust back 80px to show context above
  - Uses `Scrollable.ensureVisible()` with explicit alignment policy
  - Eliminated manual offset calculations for better reliability
- **Enhanced Anchor Text Uniqueness Algorithm**: More aggressive context expansion
  - Tries expanding around ALL occurrences when duplicates exist
  - Picks first occurrence that becomes unique with context
  - Adds 2 words at a time after initial iterations for faster convergence
  - Increased max expansions from 10 to 15 words per direction
  - Supports up to 30 total words of context (15 before + 15 after)
- **Badge Icon Style**: Changed from filled to outlined bookmark icons
  - Gutter badges: `CupertinoIcons.bookmark` (outlined)
  - Count badge: `CupertinoIcons.bookmark` (outlined)
  - Cleaner, more refined appearance with better visual hierarchy
- **Annotation Parser Optimization**: Simplified marker handling
  - Strips both annotation and element markers before saving
  - Preserves markers during display for functionality
  - Clean markdown files without rendering artifacts

### Fixed
- **Parser Crash Eliminated**: Removed problematic element marker injection
  - Element markers `[](#ln-X)` caused "BlockParser.parseLines is not advancing" error
  - Reverted to anchor text search with aggressive uniqueness algorithm
  - Files now save cleanly without element index markers
- **Annotation Marker Visibility**: Fixed invisible markers issue
  - Changed builder registration from 'html' to 'a' tag
  - Markers now properly render with emoji icons
  - GlobalKey attachment works correctly for scroll-to functionality

### Technical
- Created `_SpeechBubbleTooltip` stateful widget with Overlay positioning
- Implemented `_SpeechBubblePainter` CustomPainter for bubble shape rendering
- Enhanced `AnnotationParser.serialize()` to inject emoji-based markers
- Updated `MarkdownElementIndexer` to recognize both marker formats
- Simplified `AnnotationMarkerBuilder` to attach GlobalKeys without custom rendering
- Modified uniqueness algorithm to try all occurrences iteratively
- Added `_findAllOccurrences()` helper method for position tracking

---

## [1.4.0 "Jamaica Rum"] - 2025-12-05

### Added
- **Help Menu Integration**: Native macOS Help menu now displays user documentation
  - Added "Florence Documentation Help" menu item with Cmd+? keyboard shortcut
  - Created platform channel for Swift-to-Flutter communication
  - Implemented help dialog with full user guide content
  - Embedded complete GitHub workflow documentation for easy access
- **Version Display in About Dialog**: Application version and codename now properly displayed
  - Configured MARKETING_VERSION in AppInfo.xcconfig to show version with codename
  - About dialog now displays version as "1.4.0 'Jamaica Rum'"
  - Copyright information properly configured

### Changed
- **Improved Annotation Scrolling Algorithm**: Replaced height-calculation approach with HTML marker system
  - Injected invisible HTML comment markers (`<!-- ANNOTATION_KEY=xxxxx -->`) at annotation positions
  - Implemented custom HTML builder to attach GlobalKeys to marker widgets
  - Scroll-to-annotation now uses exact RenderBox positions instead of estimated heights
  - Eliminated fragile calculations that broke with theme/font changes
  - Reduced scroll logic from ~120 lines to ~50 lines with better accuracy
- **Enhanced DMG Packaging Script**: Automated version synchronization
  - Script now automatically extracts version name and product name from AppInfo.xcconfig
  - DMG filename dynamically generated from configuration files
  - Added validation checks for proper configuration setup
  - Single source of truth for version information across all build artifacts

### Fixed
- Annotation scroll positioning now accurate regardless of document complexity
- About dialog displays correct version information on first launch
- Product name consistency across macOS menu bar and application bundle

### Technical
- Added MethodChannel `com.florence.docs/menu` for native menu communication
- Created HtmlCommentBuilder for processing annotation markers in markdown
- Updated MainMenu.xib with Help menu item and action binding
- Enhanced AppDelegate.swift with menu action handling
- Improved content_area.dart scroll logic using GlobalKeys and RenderBox positioning

---

## [1.3.0 "Barbados"] - 2025-12-05

### Added
- **Annotation System**: Added sticky notes feature for markdown documents
  - Create annotations anchored to specific lines in documentation
  - Support for multiple highlight colors (yellow, red, blue, green, orange, purple)
  - Annotation gutter with visual indicators
  - Positioned annotation display with sidebar management
  - Persistent annotation storage across sessions
  - Tag support for categorizing annotations
- **macOS Release Packaging**: Automated DMG creation script
  - Professional DMG installer with drag-to-Applications layout
  - Custom icon support
  - Compressed distribution package
  - Automatic version extraction from pubspec.yaml
  - Deploy folder for easy distribution

### Changed
- Updated application name to "DocViewer" from internal build name
- Improved documentation screen layout to support annotation display
- Enhanced markdown viewer with annotation integration
- Updated documentation bloc to manage annotation state

### Fixed
- macOS build configuration for proper app naming
- Product name consistency across build configurations

### Technical
- Added annotation domain entities and infrastructure services
- Implemented annotation parser for persistent storage
- Created annotation UI widgets (dialog, gutter, indicators, sidebar)
- Configured AppInfo.xcconfig for consistent macOS builds
- Version management through pubspec.yaml integration

---

## [1.2.0] - Previous Release

### Added
- Markdown documentation viewer with syntax highlighting
- Theme support for documentation display
- File picker integration for loading documentation
- WebView integration for advanced rendering

### Features
- Flutter-based cross-platform architecture
- BLoC pattern for state management
- Responsive UI with Cupertino design
