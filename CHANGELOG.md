# Changelog

All notable changes to DocViewer will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
