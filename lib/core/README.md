# Core - Shared Application Code

This directory contains shared code used across multiple features.

## Structure

### `/theme`
Shared theme definitions:
- `app_theme.dart` - Light and dark theme configurations
- `seez_theme.dart` - Seez theme (vintage/warm aesthetic)

### `/widgets`
Reusable UI components used across multiple features:
- Loading indicators
- Common buttons
- Shared dialogs

### `/utils`
Utility functions and helpers:
- File system utilities
- String formatting
- Date/time helpers
- Logger utilities

### `/constants`
Application-wide constants:
- App metadata (name, version)
- Default values
- Configuration constants
- Color palettes

### `/routing`
Application routing configuration:
- `app_router.dart` - go_router configuration
- `route_paths.dart` - Route path constants and names

## Usage Guidelines

### When to add code to `core/`
- Code is used by 2+ features
- Code has no feature-specific business logic
- Code is a general utility or helper

### When NOT to add code to `core/`
- Code is feature-specific
- Code contains business logic for a single feature
- Code is only used once

### Dependencies
Features can depend on `core/`, but `core/` should never depend on features.

This ensures:
- No circular dependencies
- Clear separation of concerns
- Easy feature extraction if needed
