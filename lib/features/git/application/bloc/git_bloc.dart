import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doc_viewer_app/core/utils/app_logger.dart';
import '../../domain/repositories/git_repository.dart';
import 'git_event.dart';
import 'git_state.dart';

/// BLoC for managing Git operations
class GitBloc extends Bloc<GitEvent, GitState> {
  final GitRepository _repository;

  GitBloc({required GitRepository repository})
      : _repository = repository,
        super(const GitInitial()) {
    on<CloneRepositoryEvent>(_onCloneRepository);
    on<OpenRepositoryEvent>(_onOpenRepository);
    on<CloseRepositoryEvent>(_onCloseRepository);
    on<GetRepositoryStatusEvent>(_onGetRepositoryStatus);
    on<CommitChangesEvent>(_onCommitChanges);
    on<GetCommitHistoryEvent>(_onGetCommitHistory);
    on<PullEvent>(_onPull);
    on<PushEvent>(_onPush);
  }

  /// Handle cloning a repository
  Future<void> _onCloneRepository(
    CloneRepositoryEvent event,
    Emitter<GitState> emit,
  ) async {
    emit(const GitOperationInProgress('Cloning repository'));

    try {
      await _repository.clone(
        url: event.url,
        localPath: event.localPath,
        credentials: event.credentials,
        onProgress: (progress) {
          emit(GitOperationInProgress(
            'Cloning repository',
            progress: progress,
          ));
        },
      );

      emit(CloneSuccess(event.localPath));
    } on GitException catch (e) {
      emit(GitOperationError(
        'Failed to clone repository',
        details: e.details,
      ));
    } catch (e) {
      emit(GitOperationError(
        'Failed to clone repository',
        details: e.toString(),
      ));
    }
  }

  /// Handle opening a repository
  Future<void> _onOpenRepository(
    OpenRepositoryEvent event,
    Emitter<GitState> emit,
  ) async {
    AppLogger.info('Opening repository', tag: 'GitBloc', data: event.path);
    emit(const GitOperationInProgress('Opening repository'));

    try {
      await _repository.open(event.path);
      AppLogger.success('Repository opened successfully', tag: 'GitBloc', data: event.path);
      emit(RepositoryOpened(event.path));

      // Automatically get repository status after opening
      try {
        AppLogger.info('Fetching repository status', tag: 'GitBloc');
        final status = await _repository.status();
        AppLogger.success(
          'Repository status loaded',
          tag: 'GitBloc',
          data: 'Branch: ${status.currentBranch}, Modified: ${status.modified.length}, Added: ${status.added.length}, Deleted: ${status.deleted.length}, Untracked: ${status.untracked.length}',
        );
        emit(RepositoryStatusLoaded(status));
      } catch (statusError) {
        // If status fails, still keep repo opened but log the error
        // Don't emit error state as the repo is technically open
        AppLogger.warning('Failed to get status but repo is open', tag: 'GitBloc', data: statusError.toString());
      }
    } on GitException catch (e) {
      // If it's not a Git repository, just emit GitInitial instead of error
      // This is normal - not all folders are Git repos
      AppLogger.info('Not a Git repository', tag: 'GitBloc', data: '${event.path}\nError: ${e.message}');
      emit(const GitInitial());
    } catch (e) {
      AppLogger.warning('Error opening repository', tag: 'GitBloc', data: '${event.path}\nError: ${e.toString()}');
      emit(const GitInitial());
    }
  }

  /// Handle closing a repository
  Future<void> _onCloseRepository(
    CloseRepositoryEvent event,
    Emitter<GitState> emit,
  ) async {
    try {
      await _repository.close();
      emit(const RepositoryClosed());
    } on GitException catch (e) {
      emit(GitOperationError(
        'Failed to close repository',
        details: e.details,
      ));
    } catch (e) {
      emit(GitOperationError(
        'Failed to close repository',
        details: e.toString(),
      ));
    }
  }

  /// Handle getting repository status
  Future<void> _onGetRepositoryStatus(
    GetRepositoryStatusEvent event,
    Emitter<GitState> emit,
  ) async {
    emit(const GitOperationInProgress('Getting repository status'));

    try {
      final status = await _repository.status();
      emit(RepositoryStatusLoaded(status));
    } on GitException catch (e) {
      emit(GitOperationError(
        'Failed to get repository status',
        details: e.details,
      ));
    } catch (e) {
      emit(GitOperationError(
        'Failed to get repository status',
        details: e.toString(),
      ));
    }
  }

  /// Handle committing changes
  Future<void> _onCommitChanges(
    CommitChangesEvent event,
    Emitter<GitState> emit,
  ) async {
    emit(const GitOperationInProgress('Committing changes'));

    try {
      await _repository.commit(
        message: event.message,
        files: event.files,
      );
      emit(const CommitSuccess('Changes committed successfully'));
    } on GitException catch (e) {
      emit(GitOperationError(
        'Failed to commit changes',
        details: e.details,
      ));
    } catch (e) {
      emit(GitOperationError(
        'Failed to commit changes',
        details: e.toString(),
      ));
    }
  }

  /// Handle getting commit history
  Future<void> _onGetCommitHistory(
    GetCommitHistoryEvent event,
    Emitter<GitState> emit,
  ) async {
    emit(const GitOperationInProgress('Loading commit history'));

    try {
      final commits = await _repository.getCommitHistory(
        limit: event.limit,
        branch: event.branch,
      );
      emit(CommitHistoryLoaded(commits));
    } on GitException catch (e) {
      emit(GitOperationError(
        'Failed to load commit history',
        details: e.details,
      ));
    } catch (e) {
      emit(GitOperationError(
        'Failed to load commit history',
        details: e.toString(),
      ));
    }
  }

  /// Handle pull from remote repository
  Future<void> _onPull(
    PullEvent event,
    Emitter<GitState> emit,
  ) async {
    emit(const GitOperationInProgress('Pulling from remote repository'));

    try {
      await _repository.pull();
      emit(const PullSuccess('Successfully pulled from remote repository'));

      // Refresh status after pull
      final status = await _repository.status();
      emit(RepositoryStatusLoaded(status));
    } on GitException catch (e) {
      emit(GitOperationError(
        'Failed to pull from remote repository',
        details: e.details,
      ));
    } catch (e) {
      emit(GitOperationError(
        'Failed to pull from remote repository',
        details: e.toString(),
      ));
    }
  }

  /// Handle push to remote repository
  Future<void> _onPush(
    PushEvent event,
    Emitter<GitState> emit,
  ) async {
    emit(const GitOperationInProgress('Pushing to remote repository'));

    try {
      await _repository.push();
      emit(const PushSuccess('Successfully pushed to remote repository'));

      // Refresh status after push
      final status = await _repository.status();
      emit(RepositoryStatusLoaded(status));
    } on GitException catch (e) {
      emit(GitOperationError(
        'Failed to push to remote repository',
        details: e.details,
      ));
    } catch (e) {
      emit(GitOperationError(
        'Failed to push to remote repository',
        details: e.toString(),
      ));
    }
  }
}
