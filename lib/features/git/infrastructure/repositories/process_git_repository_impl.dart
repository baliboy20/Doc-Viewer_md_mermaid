import 'dart:convert';
import 'dart:io';

import '../../domain/entities/git_commit.dart';
import '../../domain/entities/git_conflict.dart';
import '../../domain/entities/git_credentials.dart';
import '../../domain/entities/git_status.dart' as domain;
import '../../domain/repositories/git_repository.dart';

/// Implementation of GitRepository using native git commands via Process
///
/// This implementation uses the native git command-line tool, making it
/// compatible with all architectures (Intel x86_64 and ARM64).
class ProcessGitRepositoryImpl implements GitRepository {
  String? _repositoryPath;

  @override
  bool get isOpen => _repositoryPath != null;

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

      final result = await Process.run(
        'git',
        ['clone', url, localPath],
        workingDirectory: Directory(localPath).parent.path,
      );

      if (result.exitCode != 0) {
        throw GitException(
          'Failed to clone repository',
          details: result.stderr.toString(),
        );
      }

      _repositoryPath = localPath;
    } catch (e, stackTrace) {
      if (e is GitException) rethrow;
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

      // Check if this is a valid Git repository
      final result = await Process.run(
        'git',
        ['rev-parse', '--git-dir'],
        workingDirectory: path,
      );

      if (result.exitCode != 0) {
        throw GitException(
          'Failed to open repository',
          details: 'Not a git repository: $path',
        );
      }

      _repositoryPath = path;
    } catch (e, stackTrace) {
      if (e is GitException) rethrow;
      throw GitException(
        'Failed to open repository',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> close() async {
    _repositoryPath = null;
  }

  // ========== Status Operations ==========

  @override
  Future<domain.GitStatus> status() async {
    _ensureRepositoryOpen();

    try {
      // Get status in porcelain format
      final result = await Process.run(
        'git',
        ['status', '--porcelain'],
        workingDirectory: _repositoryPath!,
      );

      if (result.exitCode != 0) {
        throw GitException(
          'Failed to get repository status',
          details: result.stderr.toString(),
        );
      }

      final modified = <String>[];
      final added = <String>[];
      final deleted = <String>[];
      final untracked = <String>[];
      final staged = <String>[];

      // Parse porcelain output
      final lines = (result.stdout as String).split('\n');
      for (final line in lines) {
        if (line.isEmpty) continue;

        final statusCode = line.substring(0, 2);
        final filePath = line.substring(3);

        // Index status (first character)
        if (statusCode[0] == 'M') {
          staged.add(filePath);
          if (!modified.contains(filePath)) modified.add(filePath);
        } else if (statusCode[0] == 'A') {
          staged.add(filePath);
          added.add(filePath);
        } else if (statusCode[0] == 'D') {
          staged.add(filePath);
          if (!deleted.contains(filePath)) deleted.add(filePath);
        }

        // Working tree status (second character)
        if (statusCode[1] == 'M') {
          if (!modified.contains(filePath)) modified.add(filePath);
        } else if (statusCode[1] == 'D') {
          if (!deleted.contains(filePath)) deleted.add(filePath);
        } else if (statusCode[1] == '?') {
          untracked.add(filePath);
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
    } catch (e, stackTrace) {
      if (e is GitException) rethrow;
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
      // Stage files
      if (files != null && files.isNotEmpty) {
        for (final file in files) {
          final addResult = await Process.run(
            'git',
            ['add', file],
            workingDirectory: _repositoryPath!,
          );

          if (addResult.exitCode != 0) {
            throw GitException(
              'Failed to stage file: $file',
              details: addResult.stderr.toString(),
            );
          }
        }
      } else {
        // Stage all changes
        final addResult = await Process.run(
          'git',
          ['add', '-A'],
          workingDirectory: _repositoryPath!,
        );

        if (addResult.exitCode != 0) {
          throw GitException(
            'Failed to stage changes',
            details: addResult.stderr.toString(),
          );
        }
      }

      // Create commit
      final args = ['commit', '-m', message];
      if (author != null) {
        args.addAll(['--author', '${author.name} <${author.email}>']);
      }

      final commitResult = await Process.run(
        'git',
        args,
        workingDirectory: _repositoryPath!,
      );

      if (commitResult.exitCode != 0) {
        throw GitException(
          'Failed to create commit',
          details: commitResult.stderr.toString(),
        );
      }
    } catch (e, stackTrace) {
      if (e is GitException) rethrow;
      throw GitException(
        'Failed to commit changes',
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
      final args = [
        'log',
        '--pretty=format:%H%n%an%n%ae%n%at%n%s%n%P',
        '--',
      ];

      if (limit != null && limit > 0) {
        args.insert(1, '-n');
        args.insert(2, limit.toString());
      }

      if (branch != null) {
        args.insert(1, branch);
      }

      final result = await Process.run(
        'git',
        args,
        workingDirectory: _repositoryPath!,
      );

      if (result.exitCode != 0) {
        throw GitException(
          'Failed to get commit history',
          details: result.stderr.toString(),
        );
      }

      final commits = <GitCommit>[];
      final output = (result.stdout as String).trim();
      if (output.isEmpty) return commits;

      final lines = output.split('\n');
      for (var i = 0; i < lines.length; i += 6) {
        if (i + 5 >= lines.length) break;

        final oid = lines[i];
        final author = lines[i + 1];
        final authorEmail = lines[i + 2];
        final timestamp = int.parse(lines[i + 3]);
        final message = lines[i + 4];
        final parents = lines[i + 5].trim();

        commits.add(GitCommit(
          oid: oid,
          message: message,
          author: author,
          authorEmail: authorEmail,
          timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
          parentOid: parents.isNotEmpty ? parents.split(' ').first : null,
        ));
      }

      return commits;
    } catch (e, stackTrace) {
      if (e is GitException) rethrow;
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
      final result = await Process.run(
        'git',
        [
          'show',
          '--pretty=format:%H%n%an%n%ae%n%at%n%s%n%P',
          '--no-patch',
          oid,
        ],
        workingDirectory: _repositoryPath!,
      );

      if (result.exitCode != 0) {
        throw GitException(
          'Failed to get commit',
          details: result.stderr.toString(),
        );
      }

      final lines = (result.stdout as String).trim().split('\n');
      if (lines.length < 6) {
        throw GitException('Invalid commit format');
      }

      final commitOid = lines[0];
      final author = lines[1];
      final authorEmail = lines[2];
      final timestamp = int.parse(lines[3]);
      final message = lines[4];
      final parents = lines[5].trim();

      return GitCommit(
        oid: commitOid,
        message: message,
        author: author,
        authorEmail: authorEmail,
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
        parentOid: parents.isNotEmpty ? parents.split(' ').first : null,
      );
    } catch (e, stackTrace) {
      if (e is GitException) rethrow;
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
      final result = await Process.run(
        'git',
        ['commit', '--amend', '-m', newMessage],
        workingDirectory: _repositoryPath!,
      );

      if (result.exitCode != 0) {
        throw GitException(
          'Failed to amend commit',
          details: result.stderr.toString(),
        );
      }
    } catch (e, stackTrace) {
      if (e is GitException) rethrow;
      throw GitException(
        'Failed to amend commit',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  // ========== Sync Operations ==========

  @override
  Future<void> fetch({
    GitCredentials? credentials,
    void Function(double progress)? onProgress,
  }) async {
    _ensureRepositoryOpen();

    try {
      final result = await Process.run(
        'git',
        ['fetch'],
        workingDirectory: _repositoryPath!,
      );

      if (result.exitCode != 0) {
        throw GitException(
          'Failed to fetch',
          details: result.stderr.toString(),
        );
      }
    } catch (e, stackTrace) {
      if (e is GitException) rethrow;
      throw GitException(
        'Failed to fetch',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> pull({
    bool rebase = false,
    GitCredentials? credentials,
    void Function(double progress)? onProgress,
  }) async {
    _ensureRepositoryOpen();

    try {
      final args = ['pull'];
      if (rebase) args.add('--rebase');

      final result = await Process.run(
        'git',
        args,
        workingDirectory: _repositoryPath!,
      );

      if (result.exitCode != 0) {
        throw GitException(
          'Failed to pull',
          details: result.stderr.toString(),
        );
      }
    } catch (e, stackTrace) {
      if (e is GitException) rethrow;
      throw GitException(
        'Failed to pull',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> push({
    bool force = false,
    GitCredentials? credentials,
    void Function(double progress)? onProgress,
  }) async {
    _ensureRepositoryOpen();

    try {
      final args = ['push'];
      if (force) args.add('--force');

      final result = await Process.run(
        'git',
        args,
        workingDirectory: _repositoryPath!,
      );

      if (result.exitCode != 0) {
        throw GitException(
          'Failed to push',
          details: result.stderr.toString(),
        );
      }
    } catch (e, stackTrace) {
      if (e is GitException) rethrow;
      throw GitException(
        'Failed to push',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
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
      final result = await Process.run(
        'git',
        ['rev-parse', '--abbrev-ref', 'HEAD'],
        workingDirectory: _repositoryPath!,
      );

      if (result.exitCode != 0) {
        throw GitException(
          'Failed to get current branch',
          details: result.stderr.toString(),
        );
      }

      return (result.stdout as String).trim();
    } catch (e, stackTrace) {
      if (e is GitException) rethrow;
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
      final result = await Process.run(
        'git',
        ['branch', '--format=%(refname:short)'],
        workingDirectory: _repositoryPath!,
      );

      if (result.exitCode != 0) {
        throw GitException(
          'Failed to get branches',
          details: result.stderr.toString(),
        );
      }

      final output = (result.stdout as String).trim();
      if (output.isEmpty) return [];

      return output.split('\n').map((b) => b.trim()).toList();
    } catch (e, stackTrace) {
      if (e is GitException) rethrow;
      throw GitException(
        'Failed to get branches',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> checkoutBranch(String branchName) async {
    _ensureRepositoryOpen();

    try {
      final result = await Process.run(
        'git',
        ['checkout', branchName],
        workingDirectory: _repositoryPath!,
      );

      if (result.exitCode != 0) {
        throw GitException(
          'Failed to checkout branch',
          details: result.stderr.toString(),
        );
      }
    } catch (e, stackTrace) {
      if (e is GitException) rethrow;
      throw GitException(
        'Failed to checkout branch',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> createBranch({
    required String branchName,
    bool checkout = true,
  }) async {
    _ensureRepositoryOpen();

    try {
      final args = ['branch', branchName];
      final result = await Process.run(
        'git',
        args,
        workingDirectory: _repositoryPath!,
      );

      if (result.exitCode != 0) {
        throw GitException(
          'Failed to create branch',
          details: result.stderr.toString(),
        );
      }

      if (checkout) {
        await checkoutBranch(branchName);
      }
    } catch (e, stackTrace) {
      if (e is GitException) rethrow;
      throw GitException(
        'Failed to create branch',
        details: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  // ========== Conflict Operations ==========

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
      final result = await Process.run(
        'git',
        ['remote', 'get-url', remoteName],
        workingDirectory: _repositoryPath!,
      );

      if (result.exitCode != 0) {
        // Remote might not exist
        return null;
      }

      return (result.stdout as String).trim();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> setRemoteUrl({
    required String url,
    String remoteName = 'origin',
  }) async {
    _ensureRepositoryOpen();

    try {
      final result = await Process.run(
        'git',
        ['remote', 'set-url', remoteName, url],
        workingDirectory: _repositoryPath!,
      );

      if (result.exitCode != 0) {
        throw GitException(
          'Failed to set remote URL',
          details: result.stderr.toString(),
        );
      }
    } catch (e, stackTrace) {
      if (e is GitException) rethrow;
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
      final result = await Process.run(
        'git',
        ['config', key],
        workingDirectory: _repositoryPath!,
      );

      if (result.exitCode != 0) {
        return null;
      }

      return (result.stdout as String).trim();
    } catch (e) {
      return null;
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
      final args = ['config'];
      if (global) args.add('--global');
      args.addAll([key, value]);

      final result = await Process.run(
        'git',
        args,
        workingDirectory: _repositoryPath!,
      );

      if (result.exitCode != 0) {
        throw GitException(
          'Failed to set config',
          details: result.stderr.toString(),
        );
      }
    } catch (e, stackTrace) {
      if (e is GitException) rethrow;
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
}
