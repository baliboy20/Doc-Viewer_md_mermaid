import 'package:git2dart/git2dart.dart' as git2;

import '../../domain/entities/git_commit.dart';
import '../../domain/entities/git_conflict.dart';
import '../../domain/entities/git_credentials.dart';
import '../../domain/entities/git_status.dart' as domain;
import '../../domain/repositories/git_repository.dart';

/// Implementation of GitRepository using git2dart (libgit2)
///
/// Note: git2dart uses synchronous operations, so we wrap them in async methods
/// to maintain a consistent interface.
class Git2DartRepositoryImpl implements GitRepository {
  git2.Repository? _repository;
  String? _repositoryPath;

  @override
  bool get isOpen => _repository != null;

  @override
  String? get repositoryPath => _repositoryPath;

  // ========== Repository Management ==========

  @override
  Future<void> clone({
    required String url,
    required String localPath,
    GitCredentials? credentials,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Close any existing repository
      if (isOpen) {
        await close();
      }

      // Set up callbacks
      final callbacks = git2.Callbacks(
        credentials: credentials != null
            ? _createCredentials(credentials)
            : null,
        transferProgress: onProgress != null
            ? (git2.TransferProgress stats) {
                if (stats.totalObjects > 0) {
                  final progress =
                      stats.receivedObjects / stats.totalObjects;
                  onProgress(progress);
                }
              }
            : null,
      );

      // Perform clone operation (synchronous in git2dart)
      _repository = git2.Repository.clone(
        url: url,
        localPath: localPath,
        callbacks: callbacks,
      );

      _repositoryPath = localPath;
    } on git2.Git2DartError catch (e) {
      throw GitException(
        'Failed to clone repository',
        details: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e, stackTrace) {
      throw GitException(
        'Failed to clone repository',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> open(String path) async {
    try {
      // Close any existing repository
      if (isOpen) {
        await close();
      }

      _repository = git2.Repository.open(path);
      _repositoryPath = path;
    } on git2.Git2DartError catch (e) {
      throw GitException(
        'Failed to open repository',
        details: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e, stackTrace) {
      throw GitException(
        'Failed to open repository',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> close() async {
    if (_repository != null) {
      _repository!.free();
      _repository = null;
      _repositoryPath = null;
    }
  }

  // ========== Status Operations ==========

  @override
  Future<domain.GitStatus> status() async {
    _ensureRepositoryOpen();

    try {
      final statusMap = _repository!.status;

      final modified = <String>[];
      final added = <String>[];
      final deleted = <String>[];
      final untracked = <String>[];
      final staged = <String>[];

      for (final entry in statusMap.entries) {
        final path = entry.key;
        final statuses = entry.value;

        // Check index (staged) changes
        if (statuses.contains(git2.GitStatus.indexNew)) {
          staged.add(path);
          added.add(path);
        }
        if (statuses.contains(git2.GitStatus.indexModified)) {
          staged.add(path);
          if (!modified.contains(path)) {
            modified.add(path);
          }
        }
        if (statuses.contains(git2.GitStatus.indexDeleted)) {
          staged.add(path);
          if (!deleted.contains(path)) {
            deleted.add(path);
          }
        }

        // Check working tree (unstaged) changes
        if (statuses.contains(git2.GitStatus.wtNew)) {
          untracked.add(path);
        }
        if (statuses.contains(git2.GitStatus.wtModified)) {
          if (!modified.contains(path)) {
            modified.add(path);
          }
        }
        if (statuses.contains(git2.GitStatus.wtDeleted)) {
          if (!deleted.contains(path)) {
            deleted.add(path);
          }
        }
      }

      final currentBranch = await getCurrentBranch();

      return domain.GitStatus(
        modified: modified,
        added: added,
        deleted: deleted,
        untracked: untracked,
        staged: staged,
        hasUncommittedChanges: modified.isNotEmpty ||
            added.isNotEmpty ||
            deleted.isNotEmpty ||
            untracked.isNotEmpty ||
            staged.isNotEmpty,
        currentBranch: currentBranch,
      );
    } on git2.Git2DartError catch (e) {
      throw GitException(
        'Failed to get repository status',
        details: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e, stackTrace) {
      throw GitException(
        'Failed to get repository status',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> hasUncommittedChanges() async {
    final status = await this.status();
    return status.hasUncommittedChanges;
  }

  @override
  Future<List<String>> getModifiedFiles() async {
    final status = await this.status();
    return [...status.modified, ...status.added, ...status.deleted];
  }

  // ========== Commit Operations ==========

  @override
  Future<void> commit({
    required String message,
    List<String>? files,
    GitAuthor? author,
  }) async {
    _ensureRepositoryOpen();

    if (message.length < 10) {
      throw GitException('Commit message must be at least 10 characters');
    }

    try {
      final index = _repository!.index;

      // Stage files
      if (files != null && files.isNotEmpty) {
        for (final file in files) {
          index.add(file);
        }
      } else {
        // Stage all changes - need to get modified files and add them
        final statusMap = _repository!.status;
        for (final path in statusMap.keys) {
          index.add(path);
        }
      }

      index.write();

      // Create tree from index
      final treeOid = index.writeTree();
      final tree = git2.Tree.lookup(repo: _repository!, oid: treeOid);

      // Get signature (author/committer)
      final git2.Signature signature;
      if (author != null) {
        signature = git2.Signature.create(
          name: author.name,
          email: author.email,
          time: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        );
      } else {
        signature = _repository!.defaultSignature;
      }

      // Get parent commit (HEAD) if it exists
      final List<git2.Commit> parents = [];
      try {
        final head = _repository!.head;
        final parentCommit = git2.Commit.lookup(
          repo: _repository!,
          oid: head.target,
        );
        parents.add(parentCommit);
      } catch (e) {
        // No parent commit (initial commit)
      }

      // Create commit
      git2.Commit.create(
        repo: _repository!,
        updateRef: 'HEAD',
        author: signature,
        committer: signature,
        message: message,
        tree: tree,
        parents: parents,
      );

      // Free resources
      tree.free();
      for (final parent in parents) {
        parent.free();
      }
      if (author != null) {
        signature.free();
      }
    } on git2.Git2DartError catch (e) {
      throw GitException(
        'Failed to create commit',
        details: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e, stackTrace) {
      throw GitException(
        'Failed to create commit',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<GitCommit>> getCommitHistory({
    int? limit,
    String? branch,
  }) async {
    _ensureRepositoryOpen();

    try {
      final commits = <GitCommit>[];

      // Get starting point (branch or HEAD)
      final git2.Reference ref;
      if (branch != null) {
        ref = git2.Reference.lookup(
          repo: _repository!,
          name: 'refs/heads/$branch',
        );
      } else {
        ref = _repository!.head;
      }

      // Create walker and configure
      final walker = git2.RevWalk(_repository!);
      walker.sorting({git2.GitSort.time});
      walker.push(ref.target);

      // Walk commits
      final commitList = walker.walk(limit: limit ?? 0);

      for (final commit in commitList) {
        commits.add(GitCommit(
          oid: commit.oid.sha,
          message: commit.message,
          author: commit.author.name,
          authorEmail: commit.author.email,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            commit.author.time * 1000,
          ),
          parentOid: commit.parents.isNotEmpty ? commit.parents.first.sha : null,
        ));
      }

      // Free resources
      for (final commit in commitList) {
        commit.free();
      }
      walker.free();
      ref.free();

      return commits;
    } on git2.Git2DartError catch (e) {
      throw GitException(
        'Failed to get commit history',
        details: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e, stackTrace) {
      throw GitException(
        'Failed to get commit history',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<GitCommit> getCommit(String oid) async {
    _ensureRepositoryOpen();

    try {
      final gitOid = git2.Oid.fromSHA(_repository!, oid);
      final commit = git2.Commit.lookup(repo: _repository!, oid: gitOid);

      final result = GitCommit(
        oid: commit.oid.sha,
        message: commit.message,
        author: commit.author.name,
        authorEmail: commit.author.email,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          commit.author.time * 1000,
        ),
        parentOid: commit.parents.isNotEmpty ? commit.parents.first.sha : null,
      );

      commit.free();
      return result;
    } on git2.Git2DartError catch (e) {
      throw GitException(
        'Failed to get commit',
        details: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e, stackTrace) {
      throw GitException(
        'Failed to get commit',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> amendLastCommit(String newMessage) async {
    _ensureRepositoryOpen();

    if (newMessage.length < 10) {
      throw GitException('Commit message must be at least 10 characters');
    }

    try {
      final head = _repository!.head;
      final lastCommit = git2.Commit.lookup(
        repo: _repository!,
        oid: head.target,
      );

      // Amend the commit with new message
      git2.Commit.amend(
        repo: _repository!,
        commit: lastCommit,
        updateRef: 'HEAD',
        message: newMessage,
      );

      lastCommit.free();
      head.free();
    } on git2.Git2DartError catch (e) {
      throw GitException(
        'Failed to amend commit',
        details: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e, stackTrace) {
      throw GitException(
        'Failed to amend commit',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  // ========== Sync Operations ==========
  // Note: These are stubs for Phase 1. Full implementation in Phase 3.

  @override
  Future<void> fetch({
    GitCredentials? credentials,
    void Function(double progress)? onProgress,
  }) async {
    throw UnimplementedError('Fetch will be implemented in Phase 3');
  }

  @override
  Future<void> pull({
    bool rebase = false,
    GitCredentials? credentials,
    void Function(double progress)? onProgress,
  }) async {
    throw UnimplementedError('Pull will be implemented in Phase 3');
  }

  @override
  Future<void> push({
    bool force = false,
    GitCredentials? credentials,
    void Function(double progress)? onProgress,
  }) async {
    throw UnimplementedError('Push will be implemented in Phase 3');
  }

  @override
  Future<domain.RemoteStatus> getRemoteStatus() async {
    throw UnimplementedError('Remote status will be implemented in Phase 3');
  }

  // ========== Branch Operations ==========

  @override
  Future<String> getCurrentBranch() async {
    _ensureRepositoryOpen();

    try {
      final head = _repository!.head;
      final branchName = head.name.replaceFirst('refs/heads/', '');
      head.free();
      return branchName;
    } on git2.Git2DartError catch (e) {
      throw GitException(
        'Failed to get current branch',
        details: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e, stackTrace) {
      throw GitException(
        'Failed to get current branch',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<String>> getBranches() async {
    _ensureRepositoryOpen();

    try {
      final branches = _repository!.branchesLocal;
      return branches.map((branch) => branch.name).toList();
    } on git2.Git2DartError catch (e) {
      throw GitException(
        'Failed to get branches',
        details: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e, stackTrace) {
      throw GitException(
        'Failed to get branches',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> checkoutBranch(String branchName) async {
    throw UnimplementedError('Branch checkout will be implemented in Phase 2');
  }

  @override
  Future<void> createBranch({
    required String branchName,
    bool checkout = true,
  }) async {
    throw UnimplementedError('Branch creation will be implemented in Phase 2');
  }

  // ========== Conflict Operations ==========
  // Note: These are stubs for Phase 1. Full implementation in Phase 4.

  @override
  Future<bool> hasConflicts() async {
    throw UnimplementedError('Conflict detection will be implemented in Phase 4');
  }

  @override
  Future<List<ConflictFile>> getConflicts() async {
    throw UnimplementedError('Conflict handling will be implemented in Phase 4');
  }

  @override
  Future<void> resolveConflict({
    required String filePath,
    required ConflictResolution resolution,
  }) async {
    throw UnimplementedError('Conflict resolution will be implemented in Phase 4');
  }

  @override
  Future<void> abortMerge() async {
    throw UnimplementedError('Merge abort will be implemented in Phase 4');
  }

  // ========== Remote Operations ==========

  @override
  Future<String?> getRemoteUrl({String remoteName = 'origin'}) async {
    _ensureRepositoryOpen();

    try {
      final remote = git2.Remote.lookup(
        repo: _repository!,
        name: remoteName,
      );
      final url = remote.url;
      remote.free();
      return url;
    } on git2.Git2DartError catch (e) {
      // Remote might not exist
      if (e.message.contains('not found') || e.message.contains('does not exist')) {
        return null;
      }
      throw GitException(
        'Failed to get remote URL',
        details: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e, stackTrace) {
      throw GitException(
        'Failed to get remote URL',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> setRemoteUrl({
    required String url,
    String remoteName = 'origin',
  }) async {
    _ensureRepositoryOpen();

    try {
      git2.Remote.setUrl(
        repo: _repository!,
        remote: remoteName,
        url: url,
      );
    } on git2.Git2DartError catch (e) {
      throw GitException(
        'Failed to set remote URL',
        details: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e, stackTrace) {
      throw GitException(
        'Failed to set remote URL',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  // ========== Configuration ==========

  @override
  Future<String?> getConfig(String key) async {
    _ensureRepositoryOpen();

    try {
      final config = _repository!.config;
      final value = config[key];
      return value.toString();
    } on git2.Git2DartError catch (e) {
      if (e.message.contains('not found')) {
        return null;
      }
      throw GitException(
        'Failed to get config',
        details: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e, stackTrace) {
      throw GitException(
        'Failed to get config',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> setConfig({
    required String key,
    required String value,
    bool global = false,
  }) async {
    _ensureRepositoryOpen();

    try {
      final config = global
          ? git2.Config.open() // Opens default config (global, XDG, system)
          : _repository!.config;
      config[key] = value;
    } on git2.Git2DartError catch (e) {
      throw GitException(
        'Failed to set config',
        details: e.message,
        stackTrace: e.stackTrace,
      );
    } catch (e, stackTrace) {
      throw GitException(
        'Failed to set config',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  // ========== Helper Methods ==========

  /// Ensures a repository is open, throws exception if not
  void _ensureRepositoryOpen() {
    if (!isOpen) {
      throw GitException('No repository is currently open');
    }
  }

  /// Creates git2dart Credentials from our domain credentials
  git2.Credentials _createCredentials(GitCredentials credentials) {
    if (credentials is UsernamePasswordCredentials) {
      return git2.UserPass(
        username: credentials.username,
        password: credentials.password,
      );
    } else if (credentials is SshKeyCredentials) {
      return git2.Keypair(
        username: credentials.username,
        pubKey: credentials.publicKeyPath,
        privateKey: credentials.privateKeyPath,
        passPhrase: credentials.passphrase ?? '',
      );
    } else if (credentials is PersonalAccessTokenCredentials) {
      // Use token as password with provided username or 'git'
      return git2.UserPass(
        username: credentials.username ?? 'git',
        password: credentials.token,
      );
    }

    throw GitException('Unsupported credential type: ${credentials.runtimeType}');
  }
}
