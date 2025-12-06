import 'package:equatable/equatable.dart';

/// Represents a file with merge conflicts
class ConflictFile extends Equatable {
  final String filePath;
  final String? localContent; // "Ours" version
  final String? remoteContent; // "Theirs" version
  final String? baseContent; // Common ancestor version
  final String? currentContent; // Current content with conflict markers
  final ConflictStatus status;

  const ConflictFile({
    required this.filePath,
    this.localContent,
    this.remoteContent,
    this.baseContent,
    this.currentContent,
    this.status = ConflictStatus.unresolved,
  });

  /// Creates a copy with the given fields updated
  ConflictFile copyWith({
    String? filePath,
    String? localContent,
    String? remoteContent,
    String? baseContent,
    String? currentContent,
    ConflictStatus? status,
  }) {
    return ConflictFile(
      filePath: filePath ?? this.filePath,
      localContent: localContent ?? this.localContent,
      remoteContent: remoteContent ?? this.remoteContent,
      baseContent: baseContent ?? this.baseContent,
      currentContent: currentContent ?? this.currentContent,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        filePath,
        localContent,
        remoteContent,
        baseContent,
        currentContent,
        status,
      ];

  @override
  String toString() => 'ConflictFile(path: $filePath, status: $status)';
}

/// Status of conflict resolution
enum ConflictStatus {
  unresolved,
  resolvedWithOurs,
  resolvedWithTheirs,
  resolvedManually,
}

/// Strategy for resolving conflicts
enum ConflictResolutionStrategy {
  acceptOurs, // Use local version
  acceptTheirs, // Use remote version
  manual, // User will manually resolve
}

/// Result of conflict resolution
class ConflictResolution extends Equatable {
  final String filePath;
  final String resolvedContent;
  final ConflictResolutionStrategy strategy;

  const ConflictResolution({
    required this.filePath,
    required this.resolvedContent,
    required this.strategy,
  });

  @override
  List<Object?> get props => [filePath, resolvedContent, strategy];

  @override
  String toString() => 'ConflictResolution(path: $filePath, strategy: $strategy)';
}
