import 'package:equatable/equatable.dart';
import '../../domain/entities/git_credentials.dart';

/// Base class for Git events
abstract class GitEvent extends Equatable {
  const GitEvent();

  @override
  List<Object?> get props => [];
}

/// Event to clone a repository
class CloneRepositoryEvent extends GitEvent {
  final String url;
  final String localPath;
  final GitCredentials? credentials;

  const CloneRepositoryEvent({
    required this.url,
    required this.localPath,
    this.credentials,
  });

  @override
  List<Object?> get props => [url, localPath, credentials];
}

/// Event to open an existing repository
class OpenRepositoryEvent extends GitEvent {
  final String path;

  const OpenRepositoryEvent(this.path);

  @override
  List<Object?> get props => [path];
}

/// Event to close the currently open repository
class CloseRepositoryEvent extends GitEvent {
  const CloseRepositoryEvent();
}

/// Event to get repository status
class GetRepositoryStatusEvent extends GitEvent {
  const GetRepositoryStatusEvent();
}

/// Event to commit changes
class CommitChangesEvent extends GitEvent {
  final String message;
  final List<String>? files;

  const CommitChangesEvent({
    required this.message,
    this.files,
  });

  @override
  List<Object?> get props => [message, files];
}

/// Event to get commit history
class GetCommitHistoryEvent extends GitEvent {
  final int? limit;
  final String? branch;

  const GetCommitHistoryEvent({
    this.limit,
    this.branch,
  });

  @override
  List<Object?> get props => [limit, branch];
}

/// Event to pull from remote repository
class PullEvent extends GitEvent {
  const PullEvent();
}

/// Event to push to remote repository
class PushEvent extends GitEvent {
  const PushEvent();
}
