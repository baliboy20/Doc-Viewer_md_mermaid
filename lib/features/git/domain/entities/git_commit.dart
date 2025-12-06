import 'package:equatable/equatable.dart';

/// Represents a Git commit
class GitCommit extends Equatable {
  final String oid; // Commit SHA hash
  final String message;
  final String author;
  final String authorEmail;
  final DateTime timestamp;
  final String? parentOid; // Parent commit SHA
  final List<String> modifiedFiles; // Files changed in this commit

  const GitCommit({
    required this.oid,
    required this.message,
    required this.author,
    required this.authorEmail,
    required this.timestamp,
    this.parentOid,
    this.modifiedFiles = const [],
  });

  /// Short version of commit hash (first 7 characters)
  String get shortOid => oid.length > 7 ? oid.substring(0, 7) : oid;

  /// First line of commit message (summary)
  String get summary {
    final lines = message.split('\n');
    return lines.isNotEmpty ? lines.first : message;
  }

  /// Full commit message body (everything after first line)
  String? get body {
    final lines = message.split('\n');
    if (lines.length <= 1) return null;
    return lines.skip(1).join('\n').trim();
  }

  @override
  List<Object?> get props => [
        oid,
        message,
        author,
        authorEmail,
        timestamp,
        parentOid,
        modifiedFiles,
      ];

  @override
  String toString() => 'GitCommit('
      'oid: $shortOid, '
      'author: $author, '
      'message: $summary, '
      'timestamp: $timestamp)';
}

/// Author information for a Git commit
class GitAuthor extends Equatable {
  final String name;
  final String email;

  const GitAuthor({
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [name, email];

  @override
  String toString() => '$name <$email>';
}
