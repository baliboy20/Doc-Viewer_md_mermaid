# Git Integration Proposal for Rome Doc Viewer

**Version:** 1.0
**Date:** 2025-12-06
**Status:** Draft
**Author:** Architecture Team

---

## Executive Summary

This proposal outlines the integration of Git version control functionality into Rome Doc Viewer, transforming it from a local-only documentation viewer into a collaborative documentation platform. The integration will enable users to:

- Clone remote documentation repositories
- Commit annotation and documentation changes locally
- Push changes to remote repositories
- Pull updates automatically on startup
- Handle common Git conflicts and synchronization issues

This enhancement positions Rome Doc Viewer as a complete documentation collaboration tool, supporting distributed teams working on shared documentation repositories.

---

## Table of Contents

1. [Background](#background)
2. [Goals and Objectives](#goals-and-objectives)
3. [User Stories](#user-stories)
4. [Technical Approach](#technical-approach)
5. [Core Features](#core-features)
6. [Potential Issues and Solutions](#potential-issues-and-solutions)
7. [Implementation Phases](#implementation-phases)
8. [Security Considerations](#security-considerations)
9. [User Experience Design](#user-experience-design)
10. [Technical Architecture](#technical-architecture)
11. [Dependencies](#dependencies)
12. [Risks and Mitigations](#risks-and-mitigations)
13. [Success Metrics](#success-metrics)

---

## Background

### Current State

Rome Doc Viewer currently operates as a standalone desktop application for viewing and annotating markdown documentation. Annotations are stored locally in markdown files, with no synchronization or version control capabilities.

### Problem Statement

1. **No Collaboration**: Users cannot share annotations or documentation changes with team members
2. **No Backup**: Local-only storage risks data loss
3. **No Version History**: Changes cannot be tracked or reverted
4. **Manual Sync**: Users must manually manage documentation updates across machines

### Opportunity

Integrating Git functionality enables:
- Seamless collaboration on documentation
- Automatic backup to remote repositories
- Version history and change tracking
- Distributed team workflows
- Integration with existing Git-based documentation workflows

---

## Goals and Objectives

### Primary Goals

1. **Enable Repository Cloning**: Users can clone existing Git repositories containing documentation
2. **Support Local Commits**: Changes to documentation and annotations can be committed with meaningful messages
3. **Enable Push Operations**: Committed changes can be pushed to remote repositories
4. **Automatic Pull on Startup**: Application fetches latest changes when launched
5. **Conflict Detection**: Identify and handle common Git conflicts gracefully

### Secondary Goals

1. Support multiple authentication methods (SSH, HTTPS, tokens)
2. Provide visual feedback on repository status
3. Enable branch management for advanced users
4. Support merge conflict resolution UI
5. Maintain compatibility with existing annotation system

### Non-Goals (Initial Release)

- Advanced Git features (rebase, cherry-pick, stash)
- Multi-repository management
- Built-in merge conflict editor
- Git LFS support
- Submodule management

---

## User Stories

### Epic 1: Repository Setup

**US-1.1: Clone Repository**
> As a documentation user, I want to clone a remote Git repository so that I can view and annotate shared documentation.

**Acceptance Criteria:**
- User can enter repository URL (HTTPS or SSH)
- User can specify local directory for cloning
- Progress indicator shows clone operation status
- Error handling for invalid URLs or network issues
- Repository opens automatically after successful clone

**US-1.2: Connect Existing Local Repository**
> As a documentation user, I want to connect to an existing local Git repository so that I can continue working on my documentation.

**Acceptance Criteria:**
- User can browse and select existing Git repository folder
- Application detects if folder is a valid Git repository
- Repository status is displayed after connection
- Warning if repository has uncommitted changes

### Epic 2: Making Changes

**US-2.1: Commit Documentation Changes**
> As a documentation contributor, I want to commit my annotation changes with a descriptive message so that my team knows what I've added.

**Acceptance Criteria:**
- UI shows list of modified files
- User can review changes (diff view)
- User can enter commit message
- Commit includes author information
- Confirmation displayed after successful commit

**US-2.2: Auto-Commit Annotations**
> As a documentation user, I want my annotations to be automatically committed periodically so that I don't lose work.

**Acceptance Criteria:**
- Option to enable auto-commit in settings
- Configurable auto-commit interval (e.g., every 5 minutes)
- Auto-generated commit messages include timestamp
- User notification when auto-commit occurs

### Epic 3: Synchronization

**US-3.1: Pull Updates on Startup**
> As a documentation user, I want the latest changes pulled automatically when I open the app so that I'm always working with current documentation.

**Acceptance Criteria:**
- Pull operation runs on application startup
- Progress indicator during pull
- Notification if updates were fetched
- Error handling for network issues or conflicts

**US-3.2: Push Changes to Remote**
> As a documentation contributor, I want to push my committed changes to the remote repository so that my team can see my work.

**Acceptance Criteria:**
- Push button visible when commits exist
- Progress indicator during push
- Success/failure notification
- Retry option on failure
- Warning if remote has new changes (suggest pull first)

**US-3.3: Manual Pull**
> As a documentation user, I want to manually pull updates so that I can get the latest changes on demand.

**Acceptance Criteria:**
- Pull button available in UI
- Shows number of commits to pull
- Handles conflicts gracefully
- Updates file tree after successful pull

### Epic 4: Conflict Management

**US-4.1: Detect Merge Conflicts**
> As a documentation user, I want to be notified of merge conflicts so that I can resolve them before continuing work.

**Acceptance Criteria:**
- Conflicts detected during pull operations
- Clear notification with list of conflicted files
- Guidance on resolution steps
- Option to abort merge

**US-4.2: Resolve Simple Conflicts**
> As a documentation user, I want to choose which version to keep for conflicted files so that I can quickly resolve conflicts.

**Acceptance Criteria:**
- UI shows conflicted files
- Options to keep: "Mine", "Theirs", or "Both" (manual)
- Preview of both versions
- Ability to edit merged result
- Commit conflict resolution

---

## Technical Approach

### Git Library Selection

**Recommended: `git2dart` (libgit2 bindings for Dart)**

**Pros:**
- Native Dart bindings to libgit2 (robust, battle-tested Git library)
- Cross-platform (macOS, Windows, Linux)
- No external Git installation required
- Comprehensive API covering all needed operations
- Active maintenance

**Alternatives Considered:**
1. **Process-based Git CLI**
   - Pros: Uses system Git, familiar command structure
   - Cons: Requires Git installation, process overhead, parsing output

2. **dart_git**
   - Pros: Pure Dart implementation
   - Cons: Limited feature set, less mature

### Architecture Pattern

**Repository Pattern with BLoC State Management**

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  ┌─────────────┐    ┌──────────────┐   │
│  │  Git Panel  │    │  Commit UI   │   │
│  └─────────────┘    └──────────────┘   │
└─────────────┬───────────────────────────┘
              │ Events/States
┌─────────────▼───────────────────────────┐
│         Application Layer               │
│  ┌──────────────────────────────────┐   │
│  │        GitBloc                   │   │
│  │  - GitState                      │   │
│  │  - GitEvent                      │   │
│  └──────────────────────────────────┘   │
└─────────────┬───────────────────────────┘
              │ Repository Interface
┌─────────────▼───────────────────────────┐
│         Domain Layer                    │
│  ┌──────────────────────────────────┐   │
│  │    GitRepository (Abstract)      │   │
│  └──────────────────────────────────┘   │
└─────────────┬───────────────────────────┘
              │ Implementation
┌─────────────▼───────────────────────────┐
│      Infrastructure Layer               │
│  ┌──────────────────────────────────┐   │
│  │  GitRepositoryImpl               │   │
│  │  (git2dart bindings)             │   │
│  └──────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

---

## Core Features

### 1. Repository Cloning

**Implementation:**
```dart
// Domain Entity
class GitRepository {
  final String localPath;
  final String? remoteUrl;
  final String? currentBranch;
  final RepositoryStatus status;

  const GitRepository({...});
}

// Repository Interface
abstract class GitRepositoryService {
  Future<Result<GitRepository>> clone({
    required String url,
    required String localPath,
    AuthCredentials? credentials,
    Function(CloneProgress)? onProgress,
  });
}
```

**Features:**
- Progress tracking (percentage, current file)
- Credential management (SSH keys, tokens, username/password)
- Shallow clone option for large repositories
- Branch selection during clone

### 2. Commit Operations

**Implementation:**
```dart
class CommitOptions {
  final String message;
  final String? author;
  final String? email;
  final bool includeAll; // git add -A
  final List<String>? specificFiles;

  const CommitOptions({...});
}

abstract class GitRepositoryService {
  Future<Result<Commit>> commit({
    required CommitOptions options,
  });

  Future<Result<List<FileChange>>> getStatus();
}
```

**Features:**
- Stage all or specific files
- Author configuration
- Commit message templates for annotations
- Pre-commit hooks (validation)

### 3. Push/Pull Operations

**Implementation:**
```dart
abstract class GitRepositoryService {
  Future<Result<PushResult>> push({
    String? remote,
    String? branch,
    bool force = false,
    AuthCredentials? credentials,
  });

  Future<Result<PullResult>> pull({
    String? remote,
    String? branch,
    PullStrategy strategy = PullStrategy.merge,
  });
}

enum PullStrategy {
  merge,
  rebase,
  fastForwardOnly,
}
```

**Features:**
- Remote detection (origin by default)
- Branch tracking
- Force push protection
- Pull strategy selection

### 4. Automatic Pull on Startup

**Implementation:**
```dart
class AppLifecycleManager {
  final GitRepositoryService _gitService;

  Future<void> onAppStartup() async {
    // Check if repository is connected
    if (_gitService.hasRepository) {
      // Check network connectivity
      if (await _networkService.isConnected()) {
        // Perform pull in background
        final result = await _gitService.pull();

        if (result.hasConflicts) {
          _showConflictNotification(result.conflicts);
        } else if (result.hasChanges) {
          _showUpdateNotification(result.changeCount);
        }
      }
    }
  }
}
```

**Features:**
- Network connectivity check before pull
- Background operation with notification
- Skip if offline
- Configurable in settings (enable/disable)

### 5. Status Monitoring

**Implementation:**
```dart
class RepositoryStatus {
  final int uncommittedChanges;
  final int commitsBehind;
  final int commitsAhead;
  final List<FileChange> modifiedFiles;
  final bool hasConflicts;
  final String? currentBranch;

  const RepositoryStatus({...});
}

// Real-time monitoring
class GitStatusMonitor {
  Stream<RepositoryStatus> watchStatus() {
    // File system watcher
    // Periodic status checks
    // Event-based updates
  }
}
```

**Features:**
- Real-time status updates
- File change detection
- Commit count badges
- Visual indicators in UI

---

## Potential Issues and Solutions

### Issue 1: Merge Conflicts on Same File

**Scenario:** Two users modify the same markdown file simultaneously.

**Detection:**
```dart
class ConflictDetector {
  Future<List<ConflictedFile>> detectConflicts() async {
    final status = await git.status();
    return status.entries
        .where((e) => e.isConflicted)
        .map((e) => ConflictedFile(
              path: e.path,
              conflictType: _determineConflictType(e),
            ))
        .toList();
  }
}
```

**Resolution Strategies:**

1. **Annotation-Specific Conflicts (Preferred)**
   - Annotations stored in separate section of markdown
   - Parse both versions, merge annotation lists
   - Auto-resolve: keep all annotations from both versions
   - Generate unique IDs to prevent duplicates

2. **Content Conflicts (User Decision)**
   - Show side-by-side diff view
   - Options: "Keep Mine", "Keep Theirs", "Edit Manually"
   - Highlight conflicting sections
   - Preserve both versions in history

**Implementation:**
```dart
class ConflictResolver {
  Future<MergeResult> resolveAnnotationConflict({
    required String filePath,
    required String baseContent,
    required String oursContent,
    required String theirsContent,
  }) async {
    // Parse annotations from both versions
    final ourAnnotations = parser.parse(oursContent).annotations;
    final theirAnnotations = parser.parse(theirsContent).annotations;

    // Merge by unique ID
    final merged = _mergeAnnotations(ourAnnotations, theirAnnotations);

    // Reconstruct file with merged annotations
    return MergeResult.success(
      content: parser.serialize(baseContent, merged),
    );
  }
}
```

### Issue 2: Repository Commits Out of Sync

**Scenario:** Local repository has diverged from remote (both have unique commits).

**Detection:**
```dart
class SyncChecker {
  Future<SyncStatus> checkSync() async {
    await git.fetch();

    final ahead = await git.commitsAhead('HEAD', 'origin/main');
    final behind = await git.commitsBehind('HEAD', 'origin/main');

    if (ahead > 0 && behind > 0) {
      return SyncStatus.diverged(ahead: ahead, behind: behind);
    } else if (behind > 0) {
      return SyncStatus.behind(count: behind);
    } else if (ahead > 0) {
      return SyncStatus.ahead(count: ahead);
    }

    return SyncStatus.synchronized();
  }
}
```

**Resolution:**

1. **Automatic (if no conflicts)**
   - Perform merge commit
   - Or rebase (configurable)
   - Notify user of resolution

2. **Manual (if conflicts exist)**
   - Block push until pull & resolve
   - Show divergence notification
   - Guide user through merge/rebase

**UI Notification:**
```
┌─────────────────────────────────────────┐
│ ⚠️  Repository Out of Sync              │
├─────────────────────────────────────────┤
│ Your local repository has:              │
│  • 3 commits ahead of remote            │
│  • 2 commits behind remote              │
│                                         │
│ Action required:                        │
│  1. Pull latest changes                │
│  2. Resolve any conflicts              │
│  3. Push your changes                  │
│                                         │
│ [Pull & Merge]  [Cancel]               │
└─────────────────────────────────────────┘
```

### Issue 3: Network Connectivity Issues

**Scenario:** Network interruption during push/pull operations.

**Detection & Handling:**
```dart
class NetworkAwareGitService {
  Future<Result<T>> executeWithRetry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        // Check network first
        if (!await _networkService.isConnected()) {
          throw NetworkException('No internet connection');
        }

        return Result.success(await operation());

      } on NetworkException catch (e) {
        if (attempt == maxRetries - 1) {
          return Result.failure(e);
        }
        attempt++;
        await Future.delayed(retryDelay * (attempt + 1));
      }
    }
  }
}
```

**User Experience:**
- Show network status indicator
- Queue operations when offline
- Auto-retry when connection restored
- Clear error messages with retry option

### Issue 4: Large Repository Performance

**Scenario:** Cloning/pulling large repositories (>1GB) takes too long.

**Solutions:**

1. **Shallow Clone**
   ```dart
   await git.clone(
     url: repoUrl,
     path: localPath,
     depth: 1, // Only latest commit
   );
   ```

2. **Sparse Checkout** (only needed folders)
   ```dart
   await git.sparseCheckout(
     patterns: ['docs/**', '*.md'],
   );
   ```

3. **Background Operations**
   ```dart
   class BackgroundGitService {
     Future<void> cloneInBackground({
       required String url,
       required Function(double) onProgress,
     }) async {
       await compute(_cloneWorker, CloneParams(url, path));
     }
   }
   ```

4. **Progress Streaming**
   ```
   ┌─────────────────────────────────────────┐
   │ 📥 Cloning Repository                   │
   ├─────────────────────────────────────────┤
   │ ████████████░░░░░░░░░░░░░░░ 45%        │
   │                                         │
   │ Receiving objects: 1,234 / 2,789       │
   │ Resolving deltas: 456 / 891            │
   │                                         │
   │ Speed: 2.3 MB/s                        │
   │ Estimated time: 1m 23s                 │
   └─────────────────────────────────────────┘
   ```

### Issue 5: Authentication Management

**Scenario:** Users need to authenticate with private repositories.

**Solutions:**

1. **SSH Key Management**
   ```dart
   class SSHAuthProvider {
     Future<SSHCredentials> loadFromSystem() async {
       final keyPath = '${Platform.environment['HOME']}/.ssh/id_rsa';
       return SSHCredentials(
         privateKeyPath: keyPath,
         passphrase: await _secureStorage.read('ssh_passphrase'),
       );
     }
   }
   ```

2. **Personal Access Tokens**
   ```dart
   class TokenAuthProvider {
     Future<void> saveToken(String token) async {
       await _secureStorage.write('git_token', token);
     }

     Future<TokenCredentials> getCredentials() async {
       return TokenCredentials(
         token: await _secureStorage.read('git_token'),
       );
     }
   }
   ```

3. **OAuth Integration** (GitHub, GitLab)
   ```dart
   class OAuthGitProvider {
     Future<OAuthCredentials> authenticateWithProvider({
       required GitProvider provider,
     }) async {
       // Launch OAuth flow
       // Receive callback
       // Store token
     }
   }
   ```

### Issue 6: Concurrent Modifications

**Scenario:** User modifies file while pull operation is in progress.

**Solution: Lock-Based Approach**
```dart
class FileLockManager {
  final Map<String, bool> _locks = {};

  Future<T> executeWithLock<T>({
    required String filePath,
    required Future<T> Function() operation,
  }) async {
    while (_locks[filePath] == true) {
      await Future.delayed(Duration(milliseconds: 100));
    }

    _locks[filePath] = true;
    try {
      return await operation();
    } finally {
      _locks[filePath] = false;
    }
  }
}
```

**User Experience:**
- Show "Syncing..." indicator on files being pulled
- Block edits during sync
- Queue user changes for after sync completes

---

## Implementation Phases

### Phase 1: Foundation (4-6 weeks)

**Milestone 1.1: Git Library Integration**
- [ ] Add git2dart dependency
- [ ] Create Git repository interface
- [ ] Implement basic clone operation
- [ ] Unit tests for Git operations

**Milestone 1.2: Basic UI Components**
- [ ] Repository setup dialog
- [ ] Git status panel
- [ ] Commit dialog
- [ ] File change list view

**Milestone 1.3: Local Operations**
- [ ] Commit functionality
- [ ] Status monitoring
- [ ] File staging
- [ ] Commit history view

**Deliverable:** Users can clone repositories and commit changes locally.

### Phase 2: Synchronization (3-4 weeks)

**Milestone 2.1: Remote Operations**
- [ ] Push implementation
- [ ] Pull implementation
- [ ] Fetch implementation
- [ ] Remote management

**Milestone 2.2: Startup Integration**
- [ ] Auto-pull on launch
- [ ] Background sync
- [ ] Network detection
- [ ] Notification system

**Milestone 2.3: Error Handling**
- [ ] Network error handling
- [ ] Authentication error handling
- [ ] Retry mechanisms
- [ ] User notifications

**Deliverable:** Full push/pull synchronization with remote repositories.

### Phase 3: Conflict Resolution (3-4 weeks)

**Milestone 3.1: Conflict Detection**
- [ ] Merge conflict detection
- [ ] Conflicted file identification
- [ ] Conflict type analysis
- [ ] Status indicators

**Milestone 3.2: Resolution UI**
- [ ] Conflict resolution dialog
- [ ] Side-by-side diff view
- [ ] Resolution options (mine/theirs/manual)
- [ ] Conflict preview

**Milestone 3.3: Smart Merging**
- [ ] Annotation auto-merge
- [ ] Content conflict handling
- [ ] Merge commit creation
- [ ] Resolution history

**Deliverable:** Users can resolve conflicts through guided UI.

### Phase 4: Polish & Advanced Features (2-3 weeks)

**Milestone 4.1: Authentication**
- [ ] SSH key support
- [ ] Token authentication
- [ ] OAuth providers
- [ ] Credential storage (secure)

**Milestone 4.2: Performance**
- [ ] Shallow clone option
- [ ] Background operations
- [ ] Progress streaming
- [ ] Large file handling

**Milestone 4.3: UX Refinement**
- [ ] Onboarding flow
- [ ] Tooltips and help
- [ ] Keyboard shortcuts
- [ ] Settings panel

**Deliverable:** Production-ready Git integration.

### Phase 5: Testing & Documentation (2 weeks)

- [ ] Integration testing
- [ ] User acceptance testing
- [ ] Performance testing
- [ ] Security audit
- [ ] User documentation
- [ ] Developer documentation

---

## Security Considerations

### 1. Credential Storage

**Requirement:** Store authentication credentials securely.

**Implementation:**
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureCredentialStore {
  final _storage = FlutterSecureStorage();

  Future<void> saveCredentials(GitCredentials credentials) async {
    await _storage.write(
      key: 'git_credentials_${credentials.repoId}',
      value: jsonEncode(credentials.toJson()),
    );
  }

  Future<void> deleteCredentials(String repoId) async {
    await _storage.delete(key: 'git_credentials_$repoId');
  }
}
```

**Best Practices:**
- Use system keychain/credential manager
- Never store passwords in plain text
- Support token-based authentication
- Implement credential expiration
- Allow credential deletion

### 2. Repository Validation

**Requirement:** Validate repository safety before cloning.

**Implementation:**
```dart
class RepositoryValidator {
  Future<ValidationResult> validate(String url) async {
    // Check URL format
    if (!_isValidGitUrl(url)) {
      return ValidationResult.invalid('Invalid Git URL format');
    }

    // Check if repository is accessible
    try {
      await git.lsRemote(url);
    } catch (e) {
      return ValidationResult.invalid('Repository not accessible');
    }

    // Check repository size (warn if >1GB)
    final size = await _getRepositorySize(url);
    if (size > 1024 * 1024 * 1024) {
      return ValidationResult.warning('Large repository (${size ~/ 1024 / 1024} MB)');
    }

    return ValidationResult.valid();
  }
}
```

### 3. Data Privacy

**Considerations:**
- Git metadata may contain sensitive information
- Commit messages might include private data
- Repository URLs might expose infrastructure details

**Mitigations:**
- Warn users about public repositories
- Option to redact sensitive information
- Clear documentation on data handling
- Support for private repositories only

### 4. Code Execution Prevention

**Risk:** Malicious Git hooks in cloned repositories.

**Mitigation:**
```dart
class SafeRepositoryManager {
  Future<void> cloneWithSafetyChecks(String url, String path) async {
    // Clone without executing hooks
    await git.clone(
      url: url,
      path: path,
      executeHooks: false,
    );

    // Scan for suspicious hook files
    final hooks = await _scanHooks(path);
    if (hooks.hasSuspicious) {
      _showWarning('Repository contains Git hooks. Review before enabling.');
    }
  }
}
```

---

## User Experience Design

### Main UI Integration

**Location:** Left sidebar panel (collapsible)

```
┌────────────────────────────────────────────────────────────┐
│  [≡] Rome Doc Viewer                    [@] Git  [⚙]      │
├────────┬───────────────────────────────────────────────────┤
│        │                                                    │
│  Git   │              Document Content                     │
│  ─────┤                                                    │
│  📁 Repo│              [📌 Annotations visible here]        │
│  ├─ origin│                                                 │
│  └─ main│                                                   │
│        │                                                    │
│  📊 Status│                                                 │
│  ↑ 2 ahead│                                                │
│  ↓ 1 behind│                                               │
│        │                                                    │
│  📝 Changes│                                                │
│  M docs.md│                                                 │
│  A new.md│                                                  │
│        │                                                    │
│  [Commit]│                                                  │
│  [Pull]│                                                    │
│  [Push]│                                                    │
│        │                                                    │
└────────┴───────────────────────────────────────────────────┘
```

### Repository Setup Flow

**Step 1: Welcome Screen**
```
┌─────────────────────────────────────────┐
│  Welcome to Rome Doc Viewer            │
├─────────────────────────────────────────┤
│  How would you like to get started?    │
│                                         │
│  🌐 Clone Remote Repository            │
│     Clone from GitHub, GitLab, etc.    │
│                                         │
│  📁 Open Local Repository              │
│     Connect to existing Git repo       │
│                                         │
│  📄 Browse Local Files                 │
│     Work without version control       │
│                                         │
└─────────────────────────────────────────┘
```

**Step 2: Clone Configuration**
```
┌─────────────────────────────────────────┐
│  Clone Repository                       │
├─────────────────────────────────────────┤
│  Repository URL:                        │
│  [https://github.com/user/docs.git   ] │
│                                         │
│  Local Path:                            │
│  [/Users/will/Documents/docs         ] │
│  [Browse...]                            │
│                                         │
│  Authentication:                        │
│  ○ None (Public)                       │
│  ● Personal Access Token               │
│  ○ SSH Key                             │
│                                         │
│  Token: [••••••••••••••••••••]         │
│                                         │
│  Advanced Options:                      │
│  ☑ Shallow clone (faster)              │
│  ☐ Clone specific branch: [______]    │
│                                         │
│  [Cancel]              [Clone]         │
└─────────────────────────────────────────┘
```

### Commit Dialog

```
┌─────────────────────────────────────────┐
│  Commit Changes                         │
├─────────────────────────────────────────┤
│  Files to commit: (2 changed)          │
│  ☑ docs/readme.md                      │
│  ☑ docs/guide.md                       │
│                                         │
│  Commit Message:                        │
│  ┌─────────────────────────────────┐   │
│  │ Add annotations to setup guide  │   │
│  │                                 │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│  Template: [Annotation Update ▾]       │
│                                         │
│  Author: will@florence.com             │
│                                         │
│  [Cancel]              [Commit]        │
└─────────────────────────────────────────┘
```

### Conflict Resolution UI

```
┌─────────────────────────────────────────────────────────────┐
│  ⚠️  Merge Conflicts Detected                               │
├─────────────────────────────────────────────────────────────┤
│  The following files have conflicts:                        │
│                                                             │
│  📄 docs/readme.md                     [Resolve]           │
│     • Content conflict in section 3                        │
│                                                             │
│  📄 docs/annotations.md                [Auto-Resolve]      │
│     • Annotation conflict (auto-mergeable)                 │
│                                                             │
│  ──────────────────────────────────────────────────────── │
│  Resolution Progress: 0 / 2                                │
│                                                             │
│  [Abort Merge]                     [Continue]              │
└─────────────────────────────────────────────────────────────┘
```

**Conflict Resolution View:**
```
┌─────────────────────────────────────────────────────────────┐
│  Resolve Conflict: docs/readme.md                           │
├──────────────────────────┬──────────────────────────────────┤
│  Your Version            │  Their Version                   │
├──────────────────────────┼──────────────────────────────────┤
│  # Setup Guide           │  # Setup Guide                   │
│                          │                                  │
│  This guide explains how │  This guide shows you how        │
│  to set up the system.   │  to configure the system.        │
│                          │                                  │
│  [Keep This Version]     │  [Keep Their Version]            │
├──────────────────────────┴──────────────────────────────────┤
│  Merged Result (Editable):                                  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │ # Setup Guide                                        │  │
│  │                                                      │  │
│  │ This guide explains how to set up and configure     │  │
│  │ the system.                                         │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  [Cancel]                      [Mark as Resolved]          │
└─────────────────────────────────────────────────────────────┘
```

### Status Indicators

**Repository Status Badge:**
```
┌────────────────┐
│ 📊 Git Status  │
├────────────────┤
│ ✓ Up to date   │  (or)
│ ↑ 2 to push    │
│ ↓ 1 to pull    │
│ ⚠ Conflicts    │
└────────────────┘
```

**File Change Indicators:**
```
M  Modified file
A  Added file
D  Deleted file
R  Renamed file
C  Conflicted file
?  Untracked file
```

---

## Technical Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Git Panel    │  │ Commit Dialog│  │ Conflict UI  │     │
│  │ Widget       │  │ Widget       │  │ Widget       │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                 │                 │              │
└─────────┼─────────────────┼─────────────────┼──────────────┘
          │                 │                 │
┌─────────▼─────────────────▼─────────────────▼──────────────┐
│                   Application Layer                         │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                    GitBloc                           │   │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐      │   │
│  │  │ GitState   │ │ GitEvent   │ │ GitMapper  │      │   │
│  │  └────────────┘ └────────────┘ └────────────┘      │   │
│  └──────────────────────────────────────────────────────┘   │
│                          │                                  │
└──────────────────────────┼──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                      Domain Layer                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Git Repository Interface                │   │
│  │  - clone()                                          │   │
│  │  - commit()                                         │   │
│  │  - push()                                           │   │
│  │  - pull()                                           │   │
│  │  - getStatus()                                      │   │
│  │  - resolveConflict()                                │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ GitRepository│  │ Commit       │  │ FileChange   │     │
│  │ Entity       │  │ Entity       │  │ Entity       │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                  Infrastructure Layer                       │
│  ┌──────────────────────────────────────────────────────┐   │
│  │          GitRepositoryImpl                           │   │
│  │  (git2dart wrapper)                                  │   │
│  └──────────────┬───────────────────────────────────────┘   │
│                 │                                           │
│  ┌──────────────▼───────────────┐  ┌──────────────┐        │
│  │ CredentialProvider           │  │ FileLock     │        │
│  │ - SSH                        │  │ Manager      │        │
│  │ - Token                      │  └──────────────┘        │
│  │ - OAuth                      │                          │
│  └──────────────────────────────┘                          │
│                                                             │
│  ┌──────────────────────────────┐  ┌──────────────┐        │
│  │ ConflictResolver             │  │ NetworkService│        │
│  │ - detectConflicts()          │  │              │        │
│  │ - autoMergeAnnotations()     │  └──────────────┘        │
│  └──────────────────────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

### Data Models

```dart
// Domain Entities

class GitRepository {
  final String id;
  final String localPath;
  final String? remoteUrl;
  final String currentBranch;
  final RepositoryStatus status;
  final List<GitRemote> remotes;

  const GitRepository({
    required this.id,
    required this.localPath,
    this.remoteUrl,
    required this.currentBranch,
    required this.status,
    required this.remotes,
  });
}

class RepositoryStatus {
  final int uncommittedChanges;
  final int commitsBehind;
  final int commitsAhead;
  final List<FileChange> changes;
  final bool hasConflicts;
  final List<ConflictedFile> conflicts;
  final DateTime lastSync;

  bool get isClean => uncommittedChanges == 0;
  bool get needsPull => commitsBehind > 0;
  bool get needsPush => commitsAhead > 0;
  bool get isDiverged => commitsBehind > 0 && commitsAhead > 0;

  const RepositoryStatus({...});
}

class FileChange {
  final String path;
  final FileChangeType type;
  final int additions;
  final int deletions;
  final bool isStaged;

  const FileChange({...});
}

enum FileChangeType {
  added,
  modified,
  deleted,
  renamed,
  conflicted,
  untracked,
}

class Commit {
  final String sha;
  final String message;
  final String author;
  final String email;
  final DateTime timestamp;
  final List<String> changedFiles;

  const Commit({...});
}

class ConflictedFile {
  final String path;
  final ConflictType type;
  final String? baseContent;
  final String oursContent;
  final String theirsContent;

  const ConflictedFile({...});
}

enum ConflictType {
  content,
  annotation,
  deletion,
  rename,
}

class GitCredentials {
  final String repoId;
  final AuthType type;
  final Map<String, dynamic> data;

  const GitCredentials({...});
}

enum AuthType {
  none,
  token,
  ssh,
  oauth,
  usernamePassword,
}
```

### State Management

```dart
// BLoC States

abstract class GitState extends Equatable {
  const GitState();
}

class GitInitial extends GitState {}

class GitRepositoryConnected extends GitState {
  final GitRepository repository;
  const GitRepositoryConnected(this.repository);
}

class GitOperationInProgress extends GitState {
  final GitOperation operation;
  final double? progress;
  const GitOperationInProgress(this.operation, [this.progress]);
}

class GitOperationSuccess extends GitState {
  final GitOperation operation;
  final String message;
  const GitOperationSuccess(this.operation, this.message);
}

class GitOperationFailure extends GitState {
  final GitOperation operation;
  final String error;
  final bool canRetry;
  const GitOperationFailure(this.operation, this.error, {this.canRetry = false});
}

class GitConflictsDetected extends GitState {
  final List<ConflictedFile> conflicts;
  const GitConflictsDetected(this.conflicts);
}

enum GitOperation {
  clone,
  pull,
  push,
  commit,
  fetch,
  merge,
}

// BLoC Events

abstract class GitEvent extends Equatable {
  const GitEvent();
}

class CloneRepositoryEvent extends GitEvent {
  final String url;
  final String localPath;
  final GitCredentials? credentials;
  final bool shallow;

  const CloneRepositoryEvent({...});
}

class ConnectRepositoryEvent extends GitEvent {
  final String localPath;
  const ConnectRepositoryEvent(this.localPath);
}

class CommitChangesEvent extends GitEvent {
  final CommitOptions options;
  const CommitChangesEvent(this.options);
}

class PushChangesEvent extends GitEvent {
  final String? remote;
  final String? branch;
  const PushChangesEvent({this.remote, this.branch});
}

class PullChangesEvent extends GitEvent {
  final String? remote;
  final String? branch;
  final PullStrategy strategy;
  const PullChangesEvent({...});
}

class ResolveConflictEvent extends GitEvent {
  final String filePath;
  final ConflictResolution resolution;
  const ResolveConflictEvent(this.filePath, this.resolution);
}

class RefreshStatusEvent extends GitEvent {}

class DisconnectRepositoryEvent extends GitEvent {}
```

---

## Dependencies

### Required Packages

```yaml
dependencies:
  # Git integration
  git2dart: ^0.8.0

  # Secure storage for credentials
  flutter_secure_storage: ^9.0.0

  # Network connectivity detection
  connectivity_plus: ^5.0.0

  # File system operations
  path: ^1.9.0
  path_provider: ^2.1.0

  # Background tasks
  workmanager: ^0.5.0

  # Existing dependencies
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  # ... (other existing dependencies)
```

### Platform-Specific Requirements

**macOS:**
- Xcode 14.0+
- macOS 11.0+ deployment target
- libgit2 (bundled with git2dart)

**Windows:**
- Visual Studio 2019+
- Windows 10+
- Git for Windows (optional, for SSH)

**Linux:**
- gcc 9+
- libgit2-dev
- libsecret (for credential storage)

---

## Risks and Mitigations

### Technical Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| git2dart compatibility issues | High | Medium | Test extensively, have fallback to CLI Git |
| Large repository performance | Medium | High | Implement shallow clone, progress indicators |
| Merge conflict complexity | High | Medium | Smart auto-merge for annotations, clear UI |
| Network reliability | Medium | High | Retry logic, offline mode, queue operations |
| Credential security | High | Low | Use secure storage, audit security practices |

### User Experience Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Git learning curve | Medium | High | Clear onboarding, tooltips, documentation |
| Accidental data loss | High | Low | Confirmation dialogs, undo operations |
| Confusion during conflicts | High | Medium | Step-by-step resolution wizard |
| Performance degradation | Medium | Medium | Background operations, progress feedback |

### Business Risks

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Scope creep | Medium | High | Strict phase boundaries, MVP focus |
| Extended timeline | Medium | Medium | Buffer time in estimates, phased delivery |
| User adoption | High | Medium | Beta testing, gather feedback early |

---

## Success Metrics

### Quantitative Metrics

1. **Adoption Rate**
   - Target: 60% of users enable Git integration within 30 days
   - Measure: User settings analytics

2. **Operation Success Rate**
   - Target: >95% successful clone operations
   - Target: >98% successful push/pull operations
   - Measure: Error logging and analytics

3. **Conflict Resolution Rate**
   - Target: 80% of annotation conflicts auto-resolved
   - Target: <5 minutes average time to resolve content conflicts
   - Measure: Conflict resolution tracking

4. **Performance**
   - Target: <30 seconds for typical repository clone
   - Target: <5 seconds for pull/push operations
   - Target: <2 seconds for status updates
   - Measure: Performance monitoring

### Qualitative Metrics

1. **User Satisfaction**
   - Survey after 2 weeks of use
   - Target: >4.0/5.0 rating on Git features

2. **Feature Usefulness**
   - Track which features are most/least used
   - Identify pain points through feedback

3. **Support Tickets**
   - Target: <10% of users need support for Git features
   - Track common issues for documentation improvement

---

## Appendix A: Glossary

- **Clone**: Copy a remote Git repository to local machine
- **Commit**: Save changes to local Git repository with a message
- **Push**: Upload local commits to remote repository
- **Pull**: Download and merge changes from remote repository
- **Merge Conflict**: Situation where same file modified in two locations
- **Fast-Forward**: Type of merge where changes can be applied linearly
- **Rebase**: Re-apply commits on top of another branch
- **Shallow Clone**: Clone with limited history (faster, smaller)
- **Remote**: A repository hosted on a server (e.g., GitHub)
- **Branch**: Parallel version of repository
- **HEAD**: Pointer to current commit/branch
- **Diverged**: Local and remote have unique commits

---

## Appendix B: Configuration Examples

### Repository Configuration File

```json
{
  "repositories": [
    {
      "id": "uuid-1234",
      "name": "Documentation Repo",
      "localPath": "/Users/will/docs",
      "remoteUrl": "https://github.com/org/docs.git",
      "branch": "main",
      "lastSync": "2025-12-06T10:30:00Z",
      "credentials": {
        "type": "token",
        "tokenRef": "secure-storage-key"
      },
      "settings": {
        "autoPullOnStartup": true,
        "autoCommitAnnotations": true,
        "autoCommitInterval": 300,
        "conflictStrategy": "auto-merge-annotations"
      }
    }
  ],
  "globalSettings": {
    "defaultAuthor": "Will Florence",
    "defaultEmail": "will@florence.com",
    "pushStrategy": "ask",
    "pullStrategy": "merge"
  }
}
```

---

## Appendix C: Future Enhancements

**Post-MVP Features** (not in initial scope):

1. **Branch Management**
   - Create/delete branches
   - Switch between branches
   - Branch visualization

2. **Advanced Merge Tools**
   - Three-way merge editor
   - Syntax-aware diff
   - Visual merge tool

3. **Git History**
   - Commit history browser
   - Blame view (who changed what)
   - File history timeline

4. **Collaboration Features**
   - Pull request integration
   - Code review workflow
   - @mentions in commits

5. **Multi-Repository Support**
   - Manage multiple repos
   - Workspace switching
   - Cross-repo search

6. **Git Hooks**
   - Pre-commit validation
   - Post-commit actions
   - Custom hook scripts

7. **Submodule Support**
   - Clone with submodules
   - Update submodules
   - Nested repository management

---

## Approval and Sign-off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Product Owner | | | |
| Tech Lead | | | |
| UX Designer | | | |
| Security Lead | | | |

---

**Document Version:** 1.0
**Last Updated:** 2025-12-06
**Next Review:** After Phase 1 completion
