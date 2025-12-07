import 'package:equatable/equatable.dart';
import '../../domain/entities/git_commit.dart';
import '../../domain/entities/git_status.dart';

/// Base class for Git states
abstract class GitState extends Equatable {
  const GitState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any Git operations
class GitInitial extends GitState {
  const GitInitial();
}

/// State when a Git operation is in progress
class GitOperationInProgress extends GitState {
  final String operation;
  final double? progress;

  const GitOperationInProgress(this.operation, {this.progress});

  @override
  List<Object?> get props => [operation, progress];
}

/// State when a repository is successfully opened
class RepositoryOpened extends GitState {
  final String path;

  const RepositoryOpened(this.path);

  @override
  List<Object?> get props => [path];
}

/// State when repository is closed
class RepositoryClosed extends GitState {
  const RepositoryClosed();
}

/// State when clone operation is successful
class CloneSuccess extends GitState {
  final String localPath;

  const CloneSuccess(this.localPath);

  @override
  List<Object?> get props => [localPath];
}

/// State when repository status is loaded
class RepositoryStatusLoaded extends GitState {
  final GitStatus status;

  const RepositoryStatusLoaded(this.status);

  @override
  List<Object?> get props => [status];
}

/// State when commit is successful
class CommitSuccess extends GitState {
  final String message;

  const CommitSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when pull is successful
class PullSuccess extends GitState {
  final String message;

  const PullSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when push is successful
class PushSuccess extends GitState {
  final String message;

  const PushSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when commit history is loaded
class CommitHistoryLoaded extends GitState {
  final List<GitCommit> commits;

  const CommitHistoryLoaded(this.commits);

  @override
  List<Object?> get props => [commits];
}

/// State when a Git operation fails
class GitOperationError extends GitState {
  final String message;
  final String? details;

  const GitOperationError(this.message, {this.details});

  @override
  List<Object?> get props => [message, details];
}
