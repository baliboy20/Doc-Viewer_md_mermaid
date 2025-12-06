import 'package:equatable/equatable.dart';

/// Status of files in a Git repository
class GitStatus extends Equatable {
  final List<String> modified;
  final List<String> added;
  final List<String> deleted;
  final List<String> untracked;
  final List<String> staged;
  final bool hasUncommittedChanges;
  final String? currentBranch;

  const GitStatus({
    required this.modified,
    required this.added,
    required this.deleted,
    required this.untracked,
    required this.staged,
    required this.hasUncommittedChanges,
    this.currentBranch,
  });

  /// Returns true if there are any changes (committed or uncommitted)
  bool get hasChanges =>
      modified.isNotEmpty ||
      added.isNotEmpty ||
      deleted.isNotEmpty ||
      untracked.isNotEmpty ||
      staged.isNotEmpty;

  /// Returns total number of changed files
  int get totalChangedFiles =>
      modified.length +
      added.length +
      deleted.length +
      untracked.length;

  @override
  List<Object?> get props => [
        modified,
        added,
        deleted,
        untracked,
        staged,
        hasUncommittedChanges,
        currentBranch,
      ];

  @override
  String toString() => 'GitStatus('
      'modified: ${modified.length}, '
      'added: ${added.length}, '
      'deleted: ${deleted.length}, '
      'untracked: ${untracked.length}, '
      'staged: ${staged.length}, '
      'branch: $currentBranch)';
}

/// Status of remote tracking
class RemoteStatus extends Equatable {
  final int commitsAhead;
  final int commitsBehind;
  final bool isUpToDate;
  final bool hasDiverged;
  final String? remoteBranch;

  const RemoteStatus({
    required this.commitsAhead,
    required this.commitsBehind,
    required this.isUpToDate,
    required this.hasDiverged,
    this.remoteBranch,
  });

  /// Returns true if local is ahead of remote
  bool get needsPush => commitsAhead > 0;

  /// Returns true if remote is ahead of local
  bool get needsPull => commitsBehind > 0;

  @override
  List<Object?> get props => [
        commitsAhead,
        commitsBehind,
        isUpToDate,
        hasDiverged,
        remoteBranch,
      ];

  @override
  String toString() => 'RemoteStatus('
      'ahead: $commitsAhead, '
      'behind: $commitsBehind, '
      'upToDate: $isUpToDate, '
      'diverged: $hasDiverged, '
      'remote: $remoteBranch)';
}
