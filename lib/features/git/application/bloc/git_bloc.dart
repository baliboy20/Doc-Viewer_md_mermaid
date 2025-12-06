import 'package:flutter_bloc/flutter_bloc.dart';
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
    emit(const GitOperationInProgress('Opening repository'));

    try {
      await _repository.open(event.path);
      emit(RepositoryOpened(event.path));
    } on GitException catch (e) {
      emit(GitOperationError(
        'Failed to open repository',
        details: e.details,
      ));
    } catch (e) {
      emit(GitOperationError(
        'Failed to open repository',
        details: e.toString(),
      ));
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
}
