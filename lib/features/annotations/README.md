# Annotations Feature

This feature handles creating, viewing, editing, and managing annotations on markdown documents.

## Status
✅ Active - Core feature

## Responsibilities
- Annotation creation with anchor text and context expansion
- Annotation storage and retrieval from markdown files
- Annotation sidebar display
- Positioned annotation badges in document gutter
- Speech bubble tooltips on badge hover
- Annotation editing and deletion
- Scroll-to-annotation functionality

## Structure
- **domain/** - Annotation entities and repository interfaces
- **infrastructure/** - Annotation parser, service, and repository implementations
- **application/** - BLoC state management for annotations
- **presentation/** - Annotation UI widgets and dialogs

## Dependencies
- Used by: `documentation` feature
- Depends on: `core` (for shared utilities)
