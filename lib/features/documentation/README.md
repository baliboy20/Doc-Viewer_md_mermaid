# Documentation Feature

This feature handles the core documentation viewing functionality including file tree navigation and markdown rendering.

## Status
✅ Active - Core feature

## Responsibilities
- File system navigation and file tree display
- Markdown document rendering with custom styling
- Theme support (Seez, Light, Dark)
- Document content display and formatting
- Mermaid diagram rendering

## Structure
- **domain/** - Business entities and repository interfaces
- **infrastructure/** - File system data sources and repository implementations
- **application/** - BLoC state management
- **presentation/** - UI screens and widgets

## Dependencies
- Depends on: `annotations` feature (for annotation markers)
- Depends on: `core` (for shared theme and utilities)
