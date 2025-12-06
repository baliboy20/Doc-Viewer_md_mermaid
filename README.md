# Florence Documentation Viewer

**Version:** 1.6.0 Nassau
**Status:** Production
**Platform:** macOS (Flutter)

A powerful documentation viewer and annotation tool built with Flutter. View markdown documentation with rich rendering, create sticky note annotations, and manage your documentation workflow with an intuitive interface.

---

## Features

### Documentation Viewing
- 📄 Rich markdown rendering with syntax highlighting
- 🌲 Tree-view navigation with hierarchical file structure
- 🎨 Customizable markdown styles (font size, line height, etc.)
- 📊 Mermaid diagram support
- 🎯 Element-level indexing for precise navigation
- 🔍 Quick file search and filtering

### Sticky Note Annotations
- 📌 Create annotations anchored to specific text or sections
- 🎨 Color-coded notes (yellow, green, blue, pink, purple)
- 🏷️ Tag-based organization
- 💾 Persistent storage in markdown files
- ✏️ Edit and update existing annotations
- 🗑️ Delete annotations with confirmation

### User Experience
- 🎨 Multiple themes (Seez, Light, Dark)
- ⚡ Fast and responsive interface
- 💾 Preferences persistence
- 🔄 Automatic file watching and updates
- ⌨️ Keyboard shortcuts
- 📱 Native macOS integration

---

## Architecture

Florence uses a **feature-based architecture** following **Domain-Driven Design (DDD)** and **Clean Architecture** principles.

### Structure

```
lib/
├── core/                    # Shared code (routing, theme, utils)
├── features/
│   ├── documentation/       # Documentation viewer feature
│   ├── annotations/         # Sticky notes feature
│   └── git/                # Git integration (Phase 2 - planned)
└── main.dart
```

Each feature is organized into four layers:
- **Domain**: Business entities and repository interfaces
- **Infrastructure**: Data sources, services, and repository implementations
- **Application**: BLoC state management and use cases
- **Presentation**: UI screens and widgets

📖 **See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed architecture documentation**

---

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK (latest stable)
- macOS 10.15 or later
- Xcode (for macOS development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd doc_viewer_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run -d macos
   ```

### Building for Release

```bash
# Build macOS app
flutter build macos --release

# App bundle location
build/macos/Build/Products/Release/doc_viewer_app.app
```

---

## Usage

### Opening Documentation

1. Launch the app
2. Click "Select Docs Folder" or use Cmd+O
3. Choose a folder containing markdown files
4. Browse the file tree and view documentation

### Creating Annotations

1. Select text in the markdown viewer
2. Click the "Add Annotation" button or use the context menu
3. Enter your note content
4. Choose a color and add optional tags
5. Save the annotation

Annotations are stored in the markdown file itself, in a dedicated annotations section at the end.

### Customizing Appearance

- Use the toolbar buttons to switch themes
- Click the settings icon to customize markdown styles
- Adjust font size, line height, and other rendering options

---

## Configuration

### Markdown Style Preferences

Customize how markdown is rendered:
- Font size (10-24px)
- Line height (1.0-2.5)
- Paragraph spacing
- Code block styles
- Link colors

Preferences are persisted using `SharedPreferences`.

### Themes

Three built-in themes:
- **Seez Theme**: Custom branded theme with teal accents
- **Light Theme**: Clean, bright interface
- **Dark Theme**: Dark mode for reduced eye strain

---

## Development

### Key Dependencies

- `flutter_bloc` ^8.1.3 - State management
- `go_router` ^14.0.0 - Declarative routing
- `flutter_markdown` ^0.7.4+1 - Markdown rendering
- `flutter_highlight` ^0.7.0 - Code syntax highlighting
- `flutter_secure_storage` ^9.0.0 - Secure credential storage
- `equatable` ^2.0.5 - Value equality
- `path` ^1.9.0 - File path utilities
- `uuid` ^4.5.1 - Unique ID generation

### Project Structure

```
doc_viewer_app/
├── lib/                    # Source code
├── macos/                  # macOS platform code
├── test/                   # Unit and widget tests
├── docs/                   # Documentation
│   ├── ARCHITECTURE.md    # Architecture guide
│   └── proposals/         # Design proposals
├── assets/                 # Static assets
├── pubspec.yaml           # Dependencies
└── README.md              # This file
```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Analyze code
flutter analyze
```

### Code Style

- Follow official [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` for consistent formatting
- Maintain 80-character line length where reasonable
- Write meaningful commit messages

---

## Roadmap

### Phase 1: Feature-Based Refactoring ✅ (v1.6.0 Nassau)
- ✅ Migrate to feature-based architecture
- ✅ Implement go_router for declarative routing
- ✅ Organize code by DDD layers
- ✅ Create comprehensive architecture documentation

### Phase 2: Git Integration 🚧 (Planned - v1.7.0)
- 📋 Version control operations
- 📋 Commit history viewing
- 📋 Diff visualization
- 📋 Branch management
- 📋 Pull/push operations

### Future Enhancements 💭
- 📋 Export annotations to various formats (PDF, HTML)
- 📋 Annotation search and filtering
- 📋 Collaborative annotations (multi-user)
- 📋 Dark mode auto-switching
- 📋 Full-text search across documentation
- 📋 Bookmark favorite pages

---

## Documentation

- [Architecture Guide](docs/ARCHITECTURE.md) - Comprehensive architecture documentation
- [Phase 1 Refactoring Plan](docs/proposals/phase-1-refactoring-plan.md) - Refactoring implementation plan
- [Git Integration Proposal](docs/proposals/git-integration-proposal.md) - Phase 2 design proposal
- [Implementation Roadmap](docs/proposals/IMPLEMENTATION_ROADMAP.md) - Overall project roadmap

---

## Contributing

### Guidelines

1. Follow the feature-based architecture pattern
2. Write tests for new features
3. Update documentation when making structural changes
4. Use BLoC pattern for state management
5. Follow the import strategy (see [ARCHITECTURE.md](docs/ARCHITECTURE.md))

### Branch Strategy

- `main` - Production-ready code
- `develop` - Integration branch
- `feature/*` - Feature branches
- `bugfix/*` - Bug fix branches
- `refactor/*` - Refactoring branches

### Commit Messages

Follow conventional commits:
```
feat: Add new annotation color options
fix: Resolve markdown rendering issue with nested lists
docs: Update architecture documentation
refactor: Extract shared widget to core
test: Add unit tests for annotation parser
```

---

## Troubleshooting

### App won't compile
```bash
flutter clean
flutter pub get
flutter run
```

### Keychain access errors (macOS)
Ensure `keychain-access-groups` is configured in entitlements:
- `macos/Runner/DebugProfile.entitlements`
- `macos/Runner/Release.entitlements`

### Markdown not rendering
- Verify file has `.md` or `.markdown` extension
- Check console for parsing errors
- Ensure file is UTF-8 encoded

### Annotations not saving
- Check file write permissions
- Verify markdown file is not read-only
- Check console for save errors

---

## License

Copyright © 2024 Florence Development Team. All rights reserved.

---

## Contact

For questions, issues, or contributions:
- Create an issue in the repository
- Contact the development team

---

**Built with ❤️ using Flutter**
