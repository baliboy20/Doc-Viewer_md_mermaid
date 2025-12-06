import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:doc_viewer_app/features/git/infrastructure/repositories/git2dart_repository_impl.dart';
import 'package:path/path.dart' as path;

/// Integration tests for Git operations
///
/// These tests verify actual Git operations using git2dart.
/// They require running on a real device or simulator.
///
/// To run these tests:
/// flutter test integration_test/git_integration_test.dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Git Integration Tests', () {
    late Git2DartRepositoryImpl repository;
    late Directory tempDir;

    setUp(() async {
      repository = Git2DartRepositoryImpl();

      // Create temporary directory for test repositories
      final systemTempDir = Directory.systemTemp;
      tempDir = await systemTempDir.createTemp('git_integration_test_');
    });

    tearDown(() async {
      // Close repository if open
      if (repository.isOpen) {
        await repository.close();
      }

      // Clean up temporary directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('clones a public repository', () async {
      final clonePath = path.join(tempDir.path, 'test_repo');

      // Clone a small public repository (git itself has a test repo)
      // Using a small, stable test repository
      await repository.clone(
        url: 'https://github.com/octocat/Hello-World.git',
        localPath: clonePath,
      );

      // Verify repository was cloned
      expect(Directory(clonePath).existsSync(), true);
      expect(Directory(path.join(clonePath, '.git')).existsSync(), true);

      // Open the repository
      await repository.open(clonePath);
      expect(repository.isOpen, true);
      expect(repository.repositoryPath, clonePath);

      // Get repository status
      final status = await repository.status();
      expect(status, isNotNull);
      expect(status.hasUncommittedChanges, false);

      // Get current branch
      final currentBranch = await repository.getCurrentBranch();
      expect(currentBranch, isNotEmpty);

      // Get commit history (limit to 5)
      final commits = await repository.getCommitHistory(limit: 5);
      expect(commits, isNotEmpty);
      expect(commits.length, lessThanOrEqualTo(5));

      // Verify commit structure
      final firstCommit = commits.first;
      expect(firstCommit.oid, isNotEmpty);
      expect(firstCommit.message, isNotEmpty);
      expect(firstCommit.author, isNotEmpty);
      expect(firstCommit.authorEmail, isNotEmpty);

      // Get remote URL
      final remoteUrl = await repository.getRemoteUrl();
      expect(remoteUrl, contains('Hello-World'));
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('handles clone with progress callback', () async {
      final clonePath = path.join(tempDir.path, 'test_repo_progress');
      final progressUpdates = <double>[];

      await repository.clone(
        url: 'https://github.com/octocat/Hello-World.git',
        localPath: clonePath,
        onProgress: (progress) {
          progressUpdates.add(progress);
        },
      );

      // Verify progress was reported
      expect(progressUpdates, isNotEmpty);

      // Progress should be between 0 and 1
      for (final progress in progressUpdates) {
        expect(progress, greaterThanOrEqualTo(0.0));
        expect(progress, lessThanOrEqualTo(1.0));
      }

      // Repository should exist
      expect(Directory(clonePath).existsSync(), true);
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('throws error for invalid repository URL', () async {
      final clonePath = path.join(tempDir.path, 'invalid_repo');

      expect(
        () => repository.clone(
          url: 'https://github.com/nonexistent/invalid-repo-12345.git',
          localPath: clonePath,
        ),
        throwsException,
      );
    });

    test('opens an existing repository', () async {
      final clonePath = path.join(tempDir.path, 'test_repo_open');

      // First clone a repository
      await repository.clone(
        url: 'https://github.com/octocat/Hello-World.git',
        localPath: clonePath,
      );

      // Close it
      await repository.close();
      expect(repository.isOpen, false);

      // Open it again
      await repository.open(clonePath);
      expect(repository.isOpen, true);
      expect(repository.repositoryPath, clonePath);

      // Should be able to perform operations
      final status = await repository.status();
      expect(status, isNotNull);
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('throws error when opening non-existent repository', () async {
      final nonExistentPath = path.join(tempDir.path, 'nonexistent');

      expect(
        () => repository.open(nonExistentPath),
        throwsException,
      );
    });

    test('gets repository branches', () async {
      final clonePath = path.join(tempDir.path, 'test_repo_branches');

      await repository.clone(
        url: 'https://github.com/octocat/Hello-World.git',
        localPath: clonePath,
      );

      await repository.open(clonePath);

      final branches = await repository.getBranches();
      expect(branches, isNotEmpty);
      expect(branches, contains('master'));
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('gets specific commit details', () async {
      final clonePath = path.join(tempDir.path, 'test_repo_commit');

      await repository.clone(
        url: 'https://github.com/octocat/Hello-World.git',
        localPath: clonePath,
      );

      await repository.open(clonePath);

      // Get first commit from history
      final commits = await repository.getCommitHistory(limit: 1);
      final firstCommit = commits.first;

      // Get the same commit by OID
      final commit = await repository.getCommit(firstCommit.oid);
      expect(commit.oid, firstCommit.oid);
      expect(commit.message, firstCommit.message);
      expect(commit.author, firstCommit.author);
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
