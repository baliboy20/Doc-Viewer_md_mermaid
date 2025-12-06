# Git Integration Proposal for Rome Doc Viewer

**Version:** 1.0
**Date:** 2025-12-06
**Author:** Development Team
**Status:** Proposal

---

## Executive Summary

This proposal outlines the integration of Git version control functionality into the Rome Doc Viewer desktop application. The integration will enable users to work with remote Git repositories, track changes to markdown documents and annotations, and synchronize their work across multiple devices or team members.

### Key Capabilities

1. **Clone Remote Repositories** - Connect to and clone remote Git repositories (GitHub, GitLab, Bitbucket, etc.)
2. **Local Commit Management** - Create commits with meaningful commit messages for document and annotation changes
3. **Push Changes** - Upload local commits to remote repositories
4. **Pull on Startup** - Automatically fetch and merge changes when the application starts
5. **Conflict Detection & Resolution** - Identify and handle merge conflicts, out-of-sync scenarios, and other Git-related issues

---

## Table of Contents

1. [Background & Motivation](#background--motivation)
2. [Requirements](#requirements)
3. [Technical Architecture](#technical-architecture)
4. [Implementation Plan](#implementation-plan)
5. [User Experience](#user-experience)
6. [Risk Assessment & Mitigation](#risk-assessment--mitigation)
7. [Success Metrics](#success-metrics)
8. [Future Enhancements](#future-enhancements)

---

## Background & Motivation

### Current State

The Rome Doc Viewer currently operates on local markdown files with an integrated annotation system. While this works well for individual users, it lacks:

- **Version control** - No history of changes to documents or annotations
- **Collaboration** - No ability to share documents and annotations with team members
- **Backup & Recovery** - No automated backup mechanism
- **Multi-device sync** - No way to work across multiple computers

### Business Value

Git integration will provide:

1. **Team Collaboration** - Multiple users can work on the same documentation with proper conflict resolution
2. **Change History** - Full audit trail of document and annotation changes
3. **Disaster Recovery** - Remote repositories serve as backups
4. **Professional Workflow** - Familiar Git workflow for technical teams
5. **Integration Readiness** - Foundation for CI/CD, automated reviews, and other DevOps practices

---

## Requirements

### Functional Requirements

#### FR-1: Repository Cloning

**Description:** Users must be able to clone remote Git repositories to their local machine.

**Acceptance Criteria:**
- Support HTTPS and SSH authentication
- Display clone progress (percentage, objects received)
- Handle large repositories (100+ MB)
- Validate repository URL before cloning
- Store credentials securely (Keychain on macOS)
- Allow user to specify local destination path
- Detect if destination path already exists
- Support private repositories with authentication

**User Stories:**
- As a user, I want to clone a remote repository so that I can work with its documents locally
- As a user, I want to provide my GitHub credentials securely so that I can access private repositories
- As a user, I want to see clone progress so that I know the operation is working

#### FR-2: Local Commit Creation

**Description:** Users must be able to commit changes to documents and annotations with descriptive messages.

**Acceptance Criteria:**
- Auto-detect changes to markdown files and annotation metadata
- Display list of changed files before commit
- Require commit message (minimum 10 characters)
- Support multi-line commit messages
- Show commit history in chronological order
- Display author information (name, email) from Git config
- Allow amending the last commit if not yet pushed
- Validate that user has configured Git identity

**User Stories:**
- As a user, I want to commit my annotation changes with a message so that I can track why I made changes
- As a user, I want to see what files have changed before committing so that I can review my work
- As a user, I want to view my commit history so that I can understand the evolution of my documents

#### FR-3: Push to Remote

**Description:** Users must be able to push their local commits to the remote repository.

**Acceptance Criteria:**
- Push all local commits not yet on remote
- Display push progress (objects sent, speed)
- Handle authentication for protected branches
- Detect if remote has diverged (requires pull first)
- Show success/failure notifications
- Support force push with confirmation (for advanced users)
- Retry mechanism for network failures

**User Stories:**
- As a user, I want to push my commits to the remote repository so that my team can see my changes
- As a user, I want to be notified if push fails so that I can take corrective action
- As a user, I want to see push progress so that I know the operation is working

#### FR-4: Pull on Startup

**Description:** Application should automatically check for and pull remote changes when launched.

**Acceptance Criteria:**
- Check for remote changes on application startup
- Display notification if new commits are available
- Automatically pull if no local uncommitted changes exist
- Prompt user if local uncommitted changes would conflict
- Show pull progress (objects received, resolving deltas)
- Update file tree view after successful pull
- Reload currently open document if it was updated
- Handle cases where remote branch has been deleted

**User Stories:**
- As a user, I want the app to automatically pull changes on startup so that I'm always working with the latest documents
- As a user, I want to be notified if pulling would overwrite my local changes so that I don't lose work
- As a user, I want to see what changed after a pull so that I can review team updates

#### FR-5: Conflict Detection & Resolution

**Description:** System must detect and assist users in resolving merge conflicts and synchronization issues.

**Acceptance Criteria:**
- Detect merge conflicts when pulling changes
- Display conflict markers in affected documents
- Provide 3-way merge view (local, remote, base)
- Allow user to choose "accept theirs", "accept mine", or manual resolution
- Detect out-of-sync scenarios (diverged history)
- Warn before operations that could cause conflicts
- Support rebase workflow as alternative to merge
- Validate that conflicts are resolved before allowing commit

**Conflict Scenarios to Handle:**

1. **Same File Modified** - Both local and remote modified the same markdown file
2. **Annotation Conflicts** - Same line annotated differently in local and remote
3. **Diverged History** - Local and remote have incompatible commit histories
4. **Deleted vs Modified** - File deleted remotely but modified locally (or vice versa)
5. **Binary File Conflicts** - Images or other binary assets changed
6. **Forced Updates** - Remote branch force-pushed, rewriting history

**User Stories:**
- As a user, I want to be notified of conflicts when pulling so that I can resolve them
- As a user, I want to see both versions of a conflicted file so that I can make an informed decision
- As a user, I want clear guidance on resolving conflicts so that I don't break the repository

### Non-Functional Requirements

#### NFR-1: Performance

- Clone operations should not block the UI
- Pull/push operations should complete in < 10 seconds for typical repositories (< 100 MB, < 1000 commits)
- Git operations should run in background threads/isolates
- UI should remain responsive during Git operations

#### NFR-2: Security

- Never store credentials in plain text
- Use macOS Keychain for credential storage
- Support SSH key authentication
- Validate SSL certificates for HTTPS connections
- Support Git credential helper protocol
- Warn users about untrusted certificates

#### NFR-3: Reliability

- Handle network interruptions gracefully
- Implement retry logic with exponential backoff
- Validate Git operations before execution
- Maintain repository integrity (avoid corrupted repositories)
- Create backups before destructive operations

#### NFR-4: Usability

- Clear, non-technical error messages
- Visual feedback for all Git operations
- Keyboard shortcuts for common Git actions (Cmd+Shift+C for commit, Cmd+Shift+P for push)
- Tooltips explaining Git concepts for non-technical users
- Undo mechanism for recent Git operations (where possible)

---

## Technical Architecture

### Technology Stack

#### Core Git Library

**Recommendation:** `git2dart` (https://pub.dev/packages/git2dart)

**Rationale:**
- Pure Dart/Flutter bindings to libgit2 (C library)
- Full Git functionality (clone, commit, push, pull, merge)
- Native performance
- Cross-platform (macOS, Windows, Linux)
- Active maintenance and community support
- No need for system Git installation

**Alternatives Considered:**
- `dart_git` - Less mature, limited functionality
- System Git via Process.run() - Platform-dependent, harder to manage credentials
- `flutter_git` - Abandoned, no recent updates

#### State Management

**Recommendation:** Extend existing BLoC architecture

**New BLoCs:**
- `GitRepositoryBloc` - Manages repository state, operations
- `GitCommitBloc` - Handles commit creation, history
- `GitSyncBloc` - Manages pull/push operations
- `GitConflictBloc` - Handles conflict detection and resolution

**Events:**
```dart
// GitRepositoryBloc Events
abstract class GitRepositoryEvent {}
class CloneRepository extends GitRepositoryEvent {
  final String url;
  final String localPath;
  final GitCredentials? credentials;
}
class OpenRepository extends GitRepositoryEvent {
  final String path;
}
class CloseRepository extends GitRepositoryEvent {}

// GitSyncBloc Events
class PullChanges extends GitSyncEvent {}
class PushChanges extends GitSyncEvent {}
class FetchRemote extends GitSyncEvent {}
class CheckRemoteStatus extends GitSyncEvent {}

// GitCommitBloc Events
class CreateCommit extends GitCommitEvent {
  final String message;
  final List<String> files;
}
class LoadCommitHistory extends GitCommitEvent {}
class AmendLastCommit extends GitCommitEvent {
  final String newMessage;
}

// GitConflictBloc Events
class DetectConflicts extends GitConflictEvent {}
class ResolveConflict extends GitConflictEvent {
  final String filePath;
  final ConflictResolution resolution;
}
class AcceptTheirs extends GitConflictEvent {
  final String filePath;
}
class AcceptMine extends GitConflictEvent {
  final String filePath;
}
```

**States:**
```dart
// GitRepositoryState
class GitRepositoryState {
  final String? currentRepoPath;
  final String? currentBranch;
  final bool isCloning;
  final double? cloneProgress;
  final String? error;
  final bool hasUncommittedChanges;
}

// GitSyncState
class GitSyncState {
  final bool isPulling;
  final bool isPushing;
  final int? localCommitsAhead;
  final int? remoteCommitsAhead;
  final DateTime? lastSync;
  final SyncStatus status; // synced, ahead, behind, diverged
}

// GitCommitState
class GitCommitState {
  final List<GitCommit> history;
  final List<String> stagedFiles;
  final List<String> unstagedFiles;
  final bool isCommitting;
}

// GitConflictState
class GitConflictState {
  final List<ConflictFile> conflicts;
  final bool hasConflicts;
  final ConflictResolutionMode mode; // merge, rebase
}
```

#### Repository Pattern

**GitRepository Interface:**
```dart
abstract class GitRepository {
  // Repository Operations
  Future<void> clone(String url, String localPath, {GitCredentials? credentials});
  Future<void> open(String path);
  Future<void> close();

  // Status Operations
  Future<GitStatus> status();
  Future<bool> hasUncommittedChanges();
  Future<List<String>> getModifiedFiles();

  // Commit Operations
  Future<void> commit(String message, {List<String>? files});
  Future<List<GitCommit>> getCommitHistory({int? limit});
  Future<void> amendLastCommit(String newMessage);

  // Sync Operations
  Future<void> pull({bool rebase = false});
  Future<void> push({bool force = false});
  Future<void> fetch();

  // Conflict Operations
  Future<List<ConflictFile>> getConflicts();
  Future<void> resolveConflict(String filePath, ConflictResolution resolution);
  Future<bool> hasConflicts();

  // Branch Operations
  Future<String> getCurrentBranch();
  Future<List<String>> getBranches();
  Future<void> checkoutBranch(String branchName);

  // Remote Operations
  Future<RemoteStatus> getRemoteStatus();
  Future<void> setRemoteUrl(String url);
}
```

**Implementation:**
```dart
class Git2DartRepository implements GitRepository {
  libgit2.Repository? _repo;

  @override
  Future<void> clone(String url, String localPath, {GitCredentials? credentials}) async {
    final options = CloneOptions();

    if (credentials != null) {
      options.fetchOptions.callbacks = RemoteCallbacks(
        credentials: (url, usernameFromUrl, allowedTypes) {
          return credentials.toLibGit2Credentials();
        },
      );
    }

    _repo = await libgit2.Repository.clone(
      url: url,
      localPath: localPath,
      options: options,
    );
  }

  @override
  Future<void> commit(String message, {List<String>? files}) async {
    if (_repo == null) throw Exception('No repository open');

    final index = await _repo!.index;

    // Stage files
    if (files != null) {
      for (final file in files) {
        await index.addByPath(file);
      }
    } else {
      await index.addAll();
    }

    await index.write();
    final treeOid = await index.writeTree();
    final tree = await _repo!.lookupTree(treeOid);

    final signature = await _repo!.defaultSignature;
    final parent = await _repo!.headCommit;

    await _repo!.createCommit(
      updateRef: 'HEAD',
      author: signature,
      committer: signature,
      message: message,
      tree: tree,
      parents: [parent],
    );
  }

  @override
  Future<void> pull({bool rebase = false}) async {
    if (_repo == null) throw Exception('No repository open');

    // Fetch
    final remote = await _repo!.remotes['origin'];
    await remote.fetch();

    // Get remote branch
    final remoteBranch = await _repo!.lookupBranch('origin/${await getCurrentBranch()}', BranchType.remote);
    final remoteCommit = await remoteBranch.target;

    // Merge or rebase
    if (rebase) {
      await _repo!.rebase(
        branch: await _repo!.head,
        upstream: remoteBranch,
      );
    } else {
      await _repo!.merge(remoteCommit);
    }
  }

  // ... other methods
}
```

#### Credential Management

**GitCredentials Model:**
```dart
abstract class GitCredentials {
  libgit2.Credential toLibGit2Credentials();
}

class UsernamePasswordCredentials extends GitCredentials {
  final String username;
  final String password;

  UsernamePasswordCredentials({required this.username, required this.password});

  @override
  libgit2.Credential toLibGit2Credentials() {
    return libgit2.Credential.userpassPlaintext(
      username: username,
      password: password,
    );
  }
}

class SshKeyCredentials extends GitCredentials {
  final String username;
  final String publicKeyPath;
  final String privateKeyPath;
  final String? passphrase;

  SshKeyCredentials({
    required this.username,
    required this.publicKeyPath,
    required this.privateKeyPath,
    this.passphrase,
  });

  @override
  libgit2.Credential toLibGit2Credentials() {
    return libgit2.Credential.sshKey(
      username: username,
      publicKey: publicKeyPath,
      privateKey: privateKeyPath,
      passphrase: passphrase ?? '',
    );
  }
}
```

**Secure Storage:**
```dart
class CredentialStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveCredentials(String repoUrl, GitCredentials credentials) async {
    if (credentials is UsernamePasswordCredentials) {
      await _storage.write(
        key: 'git_creds_$repoUrl',
        value: json.encode({
          'type': 'userpass',
          'username': credentials.username,
          'password': credentials.password,
        }),
      );
    }
    // ... handle SSH keys
  }

  Future<GitCredentials?> loadCredentials(String repoUrl) async {
    final stored = await _storage.read(key: 'git_creds_$repoUrl');
    if (stored == null) return null;

    final data = json.decode(stored);
    if (data['type'] == 'userpass') {
      return UsernamePasswordCredentials(
        username: data['username'],
        password: data['password'],
      );
    }
    // ... handle SSH keys
  }

  Future<void> deleteCredentials(String repoUrl) async {
    await _storage.delete(key: 'git_creds_$repoUrl');
  }
}
```

### Data Models

```dart
// Git Commit
class GitCommit {
  final String sha;
  final String message;
  final String author;
  final String email;
  final DateTime timestamp;
  final List<String> parentShas;

  GitCommit({
    required this.sha,
    required this.message,
    required this.author,
    required this.email,
    required this.timestamp,
    required this.parentShas,
  });
}

// Git Status
class GitStatus {
  final List<String> modified;
  final List<String> added;
  final List<String> deleted;
  final List<String> untracked;
  final List<String> conflicted;
  final bool isClean;

  GitStatus({
    required this.modified,
    required this.added,
    required this.deleted,
    required this.untracked,
    required this.conflicted,
  }) : isClean = modified.isEmpty &&
                added.isEmpty &&
                deleted.isEmpty &&
                untracked.isEmpty &&
                conflicted.isEmpty;
}

// Conflict File
class ConflictFile {
  final String path;
  final String? localContent;
  final String? remoteContent;
  final String? baseContent;
  final ConflictType type;

  ConflictFile({
    required this.path,
    this.localContent,
    this.remoteContent,
    this.baseContent,
    required this.type,
  });
}

enum ConflictType {
  contentConflict,  // Both sides modified content
  deleteModify,     // Deleted on one side, modified on other
  addAdd,           // Same file added on both sides with different content
  renameRename,     // File renamed differently on both sides
}

enum ConflictResolution {
  acceptMine,
  acceptTheirs,
  manual,
}

// Remote Status
class RemoteStatus {
  final int commitsAhead;   // How many local commits not on remote
  final int commitsBehind;  // How many remote commits not local
  final SyncStatus status;
  final DateTime? lastFetch;

  RemoteStatus({
    required this.commitsAhead,
    required this.commitsBehind,
    required this.status,
    this.lastFetch,
  });
}

enum SyncStatus {
  synced,    // Local and remote are identical
  ahead,     // Local has commits not on remote (can push)
  behind,    // Remote has commits not local (should pull)
  diverged,  // Both have unique commits (requires merge/rebase)
}
```

### File Structure

```
lib/
├── domain/
│   ├── entities/
│   │   ├── git_commit.dart
│   │   ├── git_status.dart
│   │   ├── git_credentials.dart
│   │   ├── conflict_file.dart
│   │   └── remote_status.dart
│   └── repositories/
│       └── git_repository.dart
├── infrastructure/
│   ├── repositories/
│   │   └── git2dart_repository.dart
│   └── services/
│       ├── credential_storage.dart
│       └── git_conflict_resolver.dart
├── application/
│   └── blocs/
│       ├── git_repository/
│       │   ├── git_repository_bloc.dart
│       │   ├── git_repository_event.dart
│       │   └── git_repository_state.dart
│       ├── git_sync/
│       │   ├── git_sync_bloc.dart
│       │   ├── git_sync_event.dart
│       │   └── git_sync_state.dart
│       ├── git_commit/
│       │   ├── git_commit_bloc.dart
│       │   ├── git_commit_event.dart
│       │   └── git_commit_state.dart
│       └── git_conflict/
│           ├── git_conflict_bloc.dart
│           ├── git_conflict_event.dart
│           └── git_conflict_state.dart
└── presentation/
    ├── screens/
    │   ├── git_clone_screen.dart
    │   ├── git_commit_screen.dart
    │   └── git_conflict_resolution_screen.dart
    └── widgets/
        ├── git_status_indicator.dart
        ├── commit_history_list.dart
        ├── conflict_diff_viewer.dart
        └── git_credentials_dialog.dart
```

---

## Implementation Plan

### Phase 1: Foundation (Weeks 1-3)

**Objectives:**
- Set up git2dart dependency
- Create domain models and repository interface
- Implement basic repository operations (clone, open, close)
- Create credential storage system

**Deliverables:**
- GitRepository interface
- Git2DartRepository implementation (clone, open, close only)
- GitCredentials models (username/password, SSH)
- CredentialStorage service
- Unit tests for credential storage

**Success Criteria:**
- Can clone a public repository successfully
- Can clone a private repository with credentials
- Credentials are stored securely in Keychain
- No credentials stored in plain text

### Phase 2: Commit Management (Weeks 4-6)

**Objectives:**
- Implement commit creation
- Display commit history
- Show file status (modified, added, deleted)
- Create commit UI

**Deliverables:**
- GitCommitBloc with events/states
- Commit creation functionality
- Commit history view
- File status display
- Commit screen UI
- Unit tests for commit operations

**Success Criteria:**
- Can create commits with messages
- Can view commit history
- Can see which files have changed
- UI shows real-time status updates

### Phase 3: Push/Pull Operations (Weeks 7-10)

**Objectives:**
- Implement push to remote
- Implement pull from remote
- Add auto-pull on startup
- Show sync status

**Deliverables:**
- GitSyncBloc with events/states
- Push functionality with progress
- Pull functionality with progress
- Auto-pull on app startup
- Sync status indicator in UI
- Unit tests for sync operations

**Success Criteria:**
- Can push commits to remote successfully
- Can pull changes from remote
- App automatically checks for updates on startup
- Progress is shown for long operations
- Handles network errors gracefully

### Phase 4: Conflict Resolution (Weeks 11-14)

**Objectives:**
- Detect merge conflicts
- Display conflict markers
- Implement 3-way merge view
- Allow manual conflict resolution

**Deliverables:**
- GitConflictBloc with events/states
- Conflict detection system
- ConflictDiffViewer widget (3-way merge view)
- Conflict resolution screen
- GitConflictResolver service
- Unit tests for conflict detection

**Success Criteria:**
- Conflicts are detected and displayed
- User can see both versions of conflicted content
- User can choose "accept mine" or "accept theirs"
- User can manually edit to resolve conflicts
- Resolved conflicts can be committed

### Phase 5: Polish & Edge Cases (Weeks 15-17)

**Objectives:**
- Handle edge cases (diverged history, deleted branches, etc.)
- Improve error messages
- Add keyboard shortcuts
- Performance optimization
- Documentation

**Deliverables:**
- Enhanced error handling for all Git operations
- Keyboard shortcuts (Cmd+Shift+C, Cmd+Shift+P, etc.)
- User documentation
- Developer documentation
- Integration tests
- Performance benchmarks

**Success Criteria:**
- All identified edge cases handled gracefully
- Error messages are clear and actionable
- Keyboard shortcuts work correctly
- Performance meets NFR-1 requirements
- Documentation is complete and accurate

### Timeline Summary

| Phase | Duration | Key Milestone |
|-------|----------|---------------|
| Phase 1: Foundation | 3 weeks | Repository cloning works |
| Phase 2: Commit Management | 3 weeks | Can create and view commits |
| Phase 3: Push/Pull | 4 weeks | Full sync workflow operational |
| Phase 4: Conflict Resolution | 4 weeks | Conflicts can be resolved |
| Phase 5: Polish | 3 weeks | Production-ready |
| **Total** | **17 weeks** | **Full Git integration** |

---

## User Experience

### Clone Repository Flow

1. User selects "File" → "Clone Repository" from menu
2. Clone dialog appears:
   - **Repository URL** field (validates URL format)
   - **Local Path** field with "Browse" button
   - **Authentication** section (shows/hides based on URL)
     - Username field
     - Password field (obscured)
     - "Save credentials" checkbox
     - "Use SSH key" option with file picker
   - **Advanced Options** (collapsible)
     - Branch to clone
     - Depth (shallow clone support)
   - "Clone" and "Cancel" buttons
3. User enters URL, path, credentials (if needed)
4. User clicks "Clone"
5. Progress dialog shows:
   - Progress bar (0-100%)
   - Status text ("Receiving objects: 512/1024", etc.)
   - Cancel button
6. On success:
   - Dialog closes
   - Repository opens in file tree
   - Success notification appears
7. On failure:
   - Error dialog with clear message
   - Suggestions for fixing (e.g., "Check your internet connection", "Verify credentials")

### Commit Changes Flow

1. User makes changes to markdown files or annotations
2. Git status indicator in sidebar shows "3 uncommitted changes"
3. User clicks status indicator or selects "Git" → "Commit" from menu
4. Commit screen appears:
   - **Changed Files** list:
     - Checkboxes to select files to commit
     - Icons indicating change type (M=modified, A=added, D=deleted)
     - File paths
     - Diff preview on click
   - **Commit Message** text area:
     - Placeholder: "Describe your changes..."
     - Character counter
     - Validation message if too short
   - **Author** info display (name and email)
   - "Commit" and "Cancel" buttons
5. User selects files, writes commit message
6. User clicks "Commit"
7. Commit is created, screen closes
8. Success notification: "Committed 3 files"
9. Git status updates to show "1 commit ahead of origin/main"

### Push Changes Flow

1. User has local commits not on remote
2. Status indicator shows "↑ 2" (2 commits ahead)
3. User clicks status indicator or selects "Git" → "Push" from menu
4. Push confirmation dialog:
   - "Push 2 commits to origin/main?"
   - List of commits to be pushed
   - "Push" and "Cancel" buttons
5. User clicks "Push"
6. Progress dialog shows upload progress
7. On success:
   - Success notification: "Pushed 2 commits to origin/main"
   - Status indicator updates to "✓ Synced"
8. On failure (e.g., remote has new commits):
   - Error notification: "Cannot push - remote has new commits"
   - Suggestion: "Pull changes first with Git → Pull"

### Pull Changes Flow (Auto on Startup)

1. User launches application
2. App opens last repository
3. Background check for remote changes:
   - If remote has new commits and no local changes:
     - Auto-pull with notification: "Pulled 3 new commits"
   - If remote has new commits and local uncommitted changes:
     - Notification: "Remote has updates, but you have uncommitted changes. Commit or stash your changes, then pull."
   - If remote has new commits and local committed changes:
     - Notification: "Remote and local have diverged. Open Git → Pull to merge."
4. Status indicator shows current sync state

### Conflict Resolution Flow

1. User attempts to pull changes
2. System detects conflicts in `zz-document-classification.md`
3. Conflict notification appears:
   - "Merge conflicts detected in 1 file"
   - "Open Conflict Resolver" button
4. User clicks button
5. Conflict Resolution screen opens:
   - **File List** (left sidebar):
     - Files with conflicts (red icon)
     - Click to view conflict
   - **3-Way Merge View** (main area):
     - **Left pane:** "Mine" (local version)
     - **Middle pane:** "Base" (common ancestor)
     - **Right pane:** "Theirs" (remote version)
     - Conflict markers highlighted
   - **Resolution Options**:
     - "Accept Mine" button
     - "Accept Theirs" button
     - "Edit Manually" mode (allows typing in result pane)
   - **Result Pane** (bottom):
     - Shows merged result
     - Editable
   - "Save Resolution" and "Cancel" buttons
6. User reviews differences, chooses resolution
7. User clicks "Save Resolution"
8. Conflict is marked as resolved
9. When all conflicts resolved, "Complete Merge" button enables
10. User clicks "Complete Merge"
11. System creates merge commit
12. Success notification: "Merge completed successfully"

### UI Components

#### Git Status Indicator

Located in left sidebar near file tree:

```
┌─────────────────────────┐
│ 📁 Project Files        │
├─────────────────────────┤
│ Git Status              │
│                         │
│ Branch: main            │
│ Status: ↑ 2 ↓ 1        │
│ (2 ahead, 1 behind)     │
│                         │
│ [Pull] [Push] [Commit]  │
└─────────────────────────┘
```

**States:**
- ✓ Synced (green)
- ↑ N (yellow) - N commits ahead
- ↓ N (blue) - N commits behind
- ↑ N ↓ M (orange) - Diverged
- ⚠ Conflicts (red)
- 🔄 Syncing... (animated)

#### Commit History Panel

Accessible via "Git" → "History" menu:

```
┌───────────────────────────────────────────────┐
│ Commit History - main                         │
├───────────────────────────────────────────────┤
│ 🔵 (HEAD) Added annotations to section 4.1    │
│    Will Smith • 2 hours ago • abc1234         │
│    📄 zz-document-classification.md (+12 -3)  │
│                                               │
│ 🔵 Updated BRD with new data models           │
│    Will Smith • 5 hours ago • def5678         │
│    📄 poc-brd.md (+45 -12)                    │
│                                               │
│ 🔵 Initial commit                             │
│    Will Smith • 1 day ago • ghi9012           │
│    📄 README.md (+50)                         │
└───────────────────────────────────────────────┘
```

**Features:**
- Click commit to see full diff
- Right-click for options (revert, cherry-pick, etc.)
- Search commits by message or author
- Filter by file, date range, author

---

## Risk Assessment & Mitigation

### Technical Risks

#### Risk 1: Git Repository Corruption

**Likelihood:** Medium
**Impact:** High
**Description:** Improper Git operations could corrupt the local repository, causing data loss.

**Mitigation:**
- Use well-tested libgit2 library (used by GitHub Desktop, VS Code)
- Implement validation before destructive operations
- Create backups before force operations
- Add repository integrity checks on startup
- Provide "repair repository" feature

#### Risk 2: Merge Conflicts Complexity

**Likelihood:** High
**Impact:** Medium
**Description:** Users may struggle with complex merge conflicts, especially non-technical users.

**Mitigation:**
- Provide clear, guided conflict resolution UI
- Offer simple "accept mine/theirs" options for common cases
- Include tooltips and help text explaining conflicts
- Add "abort merge" option to back out safely
- Consider auto-resolution strategies for non-conflicting hunks

#### Risk 3: Credential Security

**Likelihood:** Medium
**Impact:** High
**Description:** Improper credential storage could expose sensitive information.

**Mitigation:**
- Use macOS Keychain for credential storage
- Never log credentials
- Support OAuth for GitHub/GitLab (future enhancement)
- Implement credential timeout/expiry
- Add option to "forget credentials"

#### Risk 4: Performance with Large Repositories

**Likelihood:** Medium
**Impact:** Medium
**Description:** Operations on large repositories (1000+ files, 100+ MB) may be slow or crash the app.

**Mitigation:**
- Run all Git operations in background isolates (Dart's concurrency model)
- Implement shallow clone option (clone only recent commits)
- Add progress indicators for long operations
- Set reasonable timeout limits (e.g., 5 minutes for clone)
- Test with large repositories during development

#### Risk 5: Network Issues During Sync

**Likelihood:** High
**Impact:** Low
**Description:** Network interruptions during push/pull could leave repository in inconsistent state.

**Mitigation:**
- Implement retry logic with exponential backoff
- Allow user to cancel operations cleanly
- Validate repository state after network operations
- Provide clear error messages with recovery steps
- Support resumable operations where possible (libgit2 feature)

### Operational Risks

#### Risk 6: User Learning Curve

**Likelihood:** High (for non-technical users)
**Impact:** Medium
**Description:** Users unfamiliar with Git may struggle with concepts like commits, branches, conflicts.

**Mitigation:**
- Provide in-app tooltips and help text
- Create user guide with common workflows
- Use plain language in UI ("Save to remote" instead of "Push")
- Offer "simple mode" that hides advanced Git features
- Include video tutorials

#### Risk 7: Accidental Data Loss

**Likelihood:** Medium
**Impact:** High
**Description:** Users may accidentally overwrite changes or delete commits.

**Mitigation:**
- Require confirmation for destructive operations (force push, hard reset)
- Implement "undo" feature using reflog
- Auto-backup before destructive operations
- Show diff before operations that change content
- Add "recovery mode" to restore lost commits

---

## Success Metrics

### Adoption Metrics

- **Clone Success Rate:** > 95% of clone attempts succeed
- **Active Users with Git Enabled:** > 60% of users use Git features within first month
- **Repositories Cloned:** Average 2+ repositories per user

### Performance Metrics

- **Clone Time:** < 30 seconds for typical repository (50 MB, 500 commits)
- **Push Time:** < 10 seconds for typical push (5 commits, 10 files)
- **Pull Time:** < 10 seconds for typical pull (5 commits, 10 files)
- **UI Responsiveness:** No UI freezes > 100ms during Git operations

### Reliability Metrics

- **Operation Success Rate:** > 98% of Git operations succeed (excluding network failures)
- **Conflict Resolution Rate:** > 90% of conflicts resolved without support intervention
- **Repository Corruption Rate:** < 0.1% of repositories

### User Satisfaction Metrics

- **User Satisfaction Score:** > 4.0/5.0 for Git features
- **Support Tickets:** < 5% of tickets related to Git issues
- **Feature Requests:** Track top requested Git enhancements

---

## Future Enhancements

### Phase 6: Advanced Git Features (Post-Launch)

1. **Branch Management**
   - Create, delete, rename branches
   - Visual branch graph
   - Branch switching with uncommitted changes (stash)

2. **Tag Support**
   - Create annotated tags for releases
   - Push tags to remote
   - Filter commits by tag

3. **Stash Support**
   - Stash uncommitted changes
   - Apply/pop stash
   - Stash list management

4. **Rebase Workflow**
   - Interactive rebase
   - Rebase on pull (alternative to merge)
   - Squash commits

5. **Submodule Support**
   - Clone repositories with submodules
   - Update submodules
   - Manage submodule paths

### Phase 7: Collaboration Features

1. **Pull Request Integration**
   - View open pull requests from GitHub/GitLab
   - Create pull requests from app
   - Review and comment on PRs

2. **Code Review**
   - Inline comments on diffs
   - Review status tracking
   - Approval workflow

3. **Team Dashboard**
   - See team members' commits
   - Activity feed
   - Contribution statistics

### Phase 8: Advanced Sync

1. **Multi-Remote Support**
   - Configure multiple remotes (origin, upstream)
   - Push/pull from different remotes
   - Sync with multiple repositories

2. **Partial Clone/Sparse Checkout**
   - Clone only specific directories
   - Fetch only needed files
   - Reduce local storage requirements

3. **Git LFS Support**
   - Handle large binary files efficiently
   - Configure LFS tracking patterns
   - Manage LFS storage quota

---

## Appendices

### Appendix A: Git Terminology for Users

Glossary of Git terms with plain-language explanations:

- **Repository (Repo):** A folder containing your documents and their change history
- **Clone:** Make a copy of a remote repository on your computer
- **Commit:** Save a snapshot of your changes with a description
- **Push:** Upload your commits to the remote repository
- **Pull:** Download commits from the remote repository
- **Branch:** A separate line of development (like a workspace)
- **Merge:** Combine changes from different branches
- **Conflict:** When the same part of a file is changed in different ways
- **Sync:** Make sure local and remote repositories have the same commits

### Appendix B: Example Error Messages

**Clone Failed - Invalid URL:**
```
❌ Cannot clone repository

The URL you entered is not valid:
"htps://github.com/user/repo" (missing "t" in "https")

Please check:
• URL starts with "https://" or "git@"
• Repository name is spelled correctly
• Repository exists and is accessible

[Try Again] [Cancel]
```

**Push Failed - Remote Has New Commits:**
```
⚠️ Cannot push changes

The remote repository has new commits that you don't have locally.

What happened:
Someone else pushed commits to "main" while you were working.

How to fix:
1. Pull the new commits: Git → Pull
2. Resolve any conflicts if they occur
3. Try pushing again

[Pull Now] [Cancel]
```

**Merge Conflict Detected:**
```
⚠️ Merge conflicts detected

The following files have conflicts:
• zz-document-classification.md

What this means:
You and someone else changed the same parts of these files.

What to do:
1. Click "Resolve Conflicts" to choose which changes to keep
2. Save your resolution
3. Complete the merge

[Resolve Conflicts] [Abort Merge]
```

### Appendix C: Security Considerations

#### Credential Storage

**macOS Keychain Integration:**
- Credentials stored in system Keychain (AES-256 encryption)
- Access controlled by macOS security policies
- Requires user authentication to retrieve
- Automatic cleanup on app uninstall

**SSH Key Management:**
- Support standard SSH key locations (`~/.ssh/id_rsa`, `~/.ssh/id_ed25519`)
- Never copy or store private keys
- Support SSH agent for passphrase management
- Validate key permissions (600 for private keys)

#### Network Security

**HTTPS:**
- Validate SSL/TLS certificates by default
- Option to trust self-signed certificates (with warning)
- Support custom certificate authorities

**SSH:**
- Validate host keys against `~/.ssh/known_hosts`
- Prompt user for unknown hosts
- Support manual host key verification

#### Data Protection

- Never log credentials or sensitive data
- Sanitize error messages (remove credentials from URLs)
- Clear credential cache on logout/close
- Support "private mode" that doesn't save credentials

### Appendix D: Testing Strategy

#### Unit Tests

**Repository Operations:**
- Test clone with valid/invalid URLs
- Test commit with valid/invalid messages
- Test push/pull with various network conditions
- Test conflict detection algorithms

**Credential Management:**
- Test credential storage/retrieval
- Test credential encryption
- Test credential deletion

**BLoC Layer:**
- Test all events trigger correct state transitions
- Test error states are handled correctly
- Test concurrent operations

#### Integration Tests

**End-to-End Workflows:**
- Clone → Modify → Commit → Push
- Pull with conflicts → Resolve → Complete merge
- Multi-user scenario (simulated)

**Edge Cases:**
- Large repository (1000+ files)
- Deep history (10,000+ commits)
- Binary files (images, PDFs)
- Network interruption during sync

#### Manual Testing

**User Acceptance Testing:**
- Recruit 5-10 users for beta testing
- Provide test repositories and scenarios
- Collect feedback via surveys and interviews
- Iterate based on feedback

**Cross-Platform Testing:**
- Test on macOS 13, 14, 15
- Test with various screen sizes and resolutions
- Test with different Git hosting providers (GitHub, GitLab, Bitbucket, self-hosted)

---

## Conclusion

This proposal outlines a comprehensive Git integration for the Rome Doc Viewer that will transform it from a local document viewer into a collaborative, version-controlled documentation platform.

**Key Benefits:**
- **For Individual Users:** Version control, backup, multi-device sync
- **For Teams:** Collaboration, change tracking, conflict resolution
- **For Organization:** Audit trail, disaster recovery, professional workflow

**Implementation Timeline:** 17 weeks for full implementation across 5 phases

**Next Steps:**
1. Review and approve this proposal
2. Allocate development resources
3. Set up development environment with git2dart
4. Begin Phase 1 implementation
5. Establish beta testing program

**Open Questions:**
1. Should we support GitLab/Bitbucket OAuth in Phase 1, or defer to Phase 6?
2. Do we need branch management in initial release, or can it wait for Phase 6?
3. Should we limit to single-repository mode initially, or support multi-repository from start?
4. What level of Git knowledge can we assume from our users?

**Recommendation:** Approve proposal and proceed with Phase 1 implementation.

---

**Document Version History:**

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-12-06 | Development Team | Initial proposal |

---

**References:**

- [git2dart Documentation](https://pub.dev/packages/git2dart)
- [libgit2 Documentation](https://libgit2.org/)
- [Pro Git Book](https://git-scm.com/book/en/v2)
- [GitHub API Documentation](https://docs.github.com/en/rest)
- [GitLab API Documentation](https://docs.gitlab.com/ee/api/)

---

<!-- ANNOTATIONS_SECTION_START -->

## 📌 Annotations

### 📝 Note 1
**Anchor:** "Use macOS Keychain for credential storage"
**Line:** 179
**ID:** d89805f7-dfc3-4cc9-adaf-6cedc386a5fe
**Created:** 2025-12-06 19:09:03
**Color:** yellow

this idea is too complicated, and we encrypt a text file or find a another library that will perform thistask

---

### 📝 Note 2
**Anchor:** "Open Questions:"
**Line:** 1341
**ID:** 5849f370-40f9-492d-99d4-1e2d0fb3d950
**Created:** 2025-12-06 19:13:55
**Color:** blue

Need to investigate how to restructure the existing codebase to logically incorporate a new feater. Additional Question: suggest we refactor to domain driven develpment folder layout to allow the git integration to be added as new feature, may need also to add a routing package to enable commonly understood transition patterns.

---

<!-- ANNOTATIONS_SECTION_END -->
