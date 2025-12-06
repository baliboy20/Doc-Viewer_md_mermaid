# Git Integration Tests

This directory contains integration tests for the Git functionality in Florence.

## Tests Included

- **git_integration_test.dart**: Comprehensive integration tests for Git operations including:
  - Cloning public repositories
  - Progress callback handling
  - Opening existing repositories
  - Getting repository status
  - Retrieving commit history
  - Branch operations
  - Error handling for invalid repositories

## Running Integration Tests

### Prerequisites

1. Ensure you have a device or simulator running
2. For macOS: Ensure the app is properly code-signed (development certificate required)
3. Internet connection (tests clone from GitHub)

### Run Tests

```bash
# Run on connected device/simulator
flutter test integration_test/git_integration_test.dart

# Run on specific device
flutter test integration_test/git_integration_test.dart -d <device-id>

# Run on macOS
flutter test integration_test/git_integration_test.dart -d macos

# Run on iOS simulator
flutter test integration_test/git_integration_test.dart -d iphone

# Run on Android emulator
flutter test integration_test/git_integration_test.dart -d android
```

### Known Issues

- **macOS Code Signing**: Integration tests on macOS require the app to be code-signed with a development certificate. Configure signing in Xcode:
  1. Open `macos/Runner.xcworkspace` in Xcode
  2. Select the Runner target
  3. Go to Signing & Capabilities
  4. Enable "Automatically manage signing"
  5. Select your development team

## Test Repository

Tests use the public repository: `https://github.com/octocat/Hello-World.git`

This is GitHub's official "Hello World" test repository:
- Small size (fast cloning)
- Stable (won't be deleted)
- Well-known commit history
- No authentication required

## Test Coverage

### Repository Operations
- ✅ Clone public repository
- ✅ Clone with progress callback
- ✅ Open existing repository
- ✅ Close repository
- ✅ Get repository status
- ✅ Error handling for invalid URLs
- ✅ Error handling for non-existent paths

### Commit Operations
- ✅ Get commit history with limit
- ✅ Get specific commit by OID
- ✅ Verify commit structure (oid, message, author, etc.)

### Branch Operations
- ✅ Get all branches
- ✅ Get current branch

### Remote Operations
- ✅ Get remote URL

## Future Tests

Tests for features in later phases:
- Clone private repository with credentials (Phase 2.2)
- Pull from remote (Phase 3)
- Push to remote (Phase 3)
- Commit changes (Phase 3)
- Conflict resolution (Phase 4)
- Branch creation and switching (Phase 4)

## Troubleshooting

### Build Failed - Code Signing
If you see "requires signing with a development certificate", configure Xcode signing as described above.

### Network Errors
Ensure you have a stable internet connection as tests clone from GitHub.

### Timeout Errors
Increase test timeout if cloning takes longer on your network:
```dart
test('...', () async {
  // test code
}, timeout: const Timeout(Duration(minutes: 5)));
```
