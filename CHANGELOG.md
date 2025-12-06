# Changelog

All notable changes to DocViewer will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
