import '../entities/git_commit.dart';
import '../entities/git_conflict.dart';
import '../entities/git_credentials.dart';
import '../entities/git_status.dart';

/// Repository interface for Git operations
///
/// This interface defines all Git-related operations that can be performed
/// on a repository. The implementation uses git2dart (libgit2) under the hood.
abstract class GitRepository {
  // ========== Repository Management ==========

  /// Clone a remote repository to a local path
  ///
  /// [url] - Remote repository URL (HTTPS or SSH)
  /// [localPath] - Local directory path where repository will be cloned
  /// [credentials] - Optional credentials for private repositories
  /// [onProgress] - Optional callback for clone progress (0.0 to 1.0)
  ///
  /// Throws [GitException] if clone fails
  Future<void> clone({
    required String url,
    required String localPath,
    GitCredentials? credentials,
    void Function(double progress)? onProgress,
  });

  /// Open an existing local repository
  ///
  /// [path] - Path to the repository directory
  ///
  /// Throws [GitException] if path is not a valid Git repository
  Future<void> open(String path);

  /// Close the currently open repository
  ///
  /// Should be called when done with repository operations
  Future<void> close();

  /// Check if a repository is currently open
  bool get isOpen;

  /// Get the path of the currently open repository
  String? get repositoryPath;

  // ========== Status Operations ==========

  /// Get current repository status
  ///
  /// Returns [GitStatus] with information about modified, added, deleted files
  Future<GitStatus> status();

  /// Check if repository has uncommitted changes
  ///
  /// Returns true if there are unstaged or staged changes
  Future<bool> hasUncommittedChanges();

  /// Get list of files with uncommitted changes
  ///
  /// Returns list of file paths relative to repository root
  Future<List<String>> getModifiedFiles();

  // ========== Commit Operations ==========

  /// Create a new commit
  ///
  /// [message] - Commit message (required, min 10 characters)
  /// [files] - Optional list of specific files to commit (null = all staged)
  /// [author] - Optional author override (uses Git config if not provided)
  ///
  /// Throws [GitException] if commit fails
  Future<void> commit({
    required String message,
    List<String>? files,
    GitAuthor? author,
  });

  /// Get commit history
  ///
  /// [limit] - Maximum number of commits to retrieve (null = all)
  /// [branch] - Branch to get history from (null = current branch)
  ///
  /// Returns list of commits in reverse chronological order
  Future<List<GitCommit>> getCommitHistory({
    int? limit,
    String? branch,
  });

  /// Get details of a specific commit
  ///
  /// [oid] - Commit SHA hash
  ///
  /// Throws [GitException] if commit not found
  Future<GitCommit> getCommit(String oid);

  /// Amend the last commit
  ///
  /// [newMessage] - New commit message
  ///
  /// Throws [GitException] if no commits exist or commit has been pushed
  Future<void> amendLastCommit(String newMessage);

  // ========== Sync Operations ==========

  /// Fetch changes from remote without merging
  ///
  /// [credentials] - Optional credentials for authentication
  /// [onProgress] - Optional callback for fetch progress
  ///
  /// Throws [GitException] if fetch fails
  Future<void> fetch({
    GitCredentials? credentials,
    void Function(double progress)? onProgress,
  });

  /// Pull changes from remote (fetch + merge)
  ///
  /// [rebase] - If true, use rebase instead of merge
  /// [credentials] - Optional credentials for authentication
  /// [onProgress] - Optional callback for pull progress
  ///
  /// Throws [GitException] if pull fails or conflicts occur
  Future<void> pull({
    bool rebase = false,
    GitCredentials? credentials,
    void Function(double progress)? onProgress,
  });

  /// Push local commits to remote
  ///
  /// [force] - If true, force push (use with caution!)
  /// [credentials] - Optional credentials for authentication
  /// [onProgress] - Optional callback for push progress
  ///
  /// Throws [GitException] if push fails
  Future<void> push({
    bool force = false,
    GitCredentials? credentials,
    void Function(double progress)? onProgress,
  });

  /// Get status of local vs remote
  ///
  /// Returns [RemoteStatus] with ahead/behind commit counts
  Future<RemoteStatus> getRemoteStatus();

  // ========== Branch Operations ==========

  /// Get name of current branch
  ///
  /// Returns branch name (e.g., "main", "develop")
  Future<String> getCurrentBranch();

  /// Get list of all local branches
  ///
  /// Returns list of branch names
  Future<List<String>> getBranches();

  /// Switch to a different branch
  ///
  /// [branchName] - Name of branch to checkout
  ///
  /// Throws [GitException] if branch doesn't exist or has uncommitted changes
  Future<void> checkoutBranch(String branchName);

  /// Create a new branch
  ///
  /// [branchName] - Name for the new branch
  /// [checkout] - If true, switch to the new branch after creating
  ///
  /// Throws [GitException] if branch already exists
  Future<void> createBranch({
    required String branchName,
    bool checkout = true,
  });

  // ========== Conflict Operations ==========

  /// Check if repository has merge conflicts
  ///
  /// Returns true if there are unresolved conflicts
  Future<bool> hasConflicts();

  /// Get list of files with conflicts
  ///
  /// Returns list of [ConflictFile] with conflict details
  Future<List<ConflictFile>> getConflicts();

  /// Resolve a conflict
  ///
  /// [filePath] - Path to the conflicted file
  /// [resolution] - Resolution strategy and content
  ///
  /// Throws [GitException] if resolution fails
  Future<void> resolveConflict({
    required String filePath,
    required ConflictResolution resolution,
  });

  /// Abort merge/rebase operation
  ///
  /// Restores repository to state before merge/rebase
  ///
  /// Throws [GitException] if not in merge/rebase state
  Future<void> abortMerge();

  // ========== Remote Operations ==========

  /// Get URL of the remote repository
  ///
  /// [remoteName] - Name of remote (default: "origin")
  ///
  /// Returns remote URL or null if remote doesn't exist
  Future<String?> getRemoteUrl({String remoteName = 'origin'});

  /// Set or update remote URL
  ///
  /// [url] - New remote URL
  /// [remoteName] - Name of remote (default: "origin")
  ///
  /// Throws [GitException] if operation fails
  Future<void> setRemoteUrl({
    required String url,
    String remoteName = 'origin',
  });

  // ========== Configuration ==========

  /// Get Git config value
  ///
  /// [key] - Config key (e.g., "user.name", "user.email")
  ///
  /// Returns config value or null if not set
  Future<String?> getConfig(String key);

  /// Set Git config value
  ///
  /// [key] - Config key (e.g., "user.name", "user.email")
  /// [value] - Config value
  /// [global] - If true, set globally; otherwise repository-specific
  ///
  /// Throws [GitException] if operation fails
  Future<void> setConfig({
    required String key,
    required String value,
    bool global = false,
  });
}

/// Exception thrown by Git operations
class GitException implements Exception {
  final String message;
  final String? details;
  final StackTrace? stackTrace;

  GitException(this.message, {this.details, this.stackTrace});

  @override
  String toString() {
    if (details != null) {
      return 'GitException: $message\nDetails: $details';
    }
    return 'GitException: $message';
  }
}
