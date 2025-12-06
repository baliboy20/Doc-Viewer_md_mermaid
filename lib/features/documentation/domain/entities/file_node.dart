import 'package:equatable/equatable.dart';

/// Represents a file or directory node in the documentation file tree
class FileNode extends Equatable {
  final String path;
  final String name;
  final bool isDirectory;
  final List<FileNode> children;

  const FileNode({
    required this.path,
    required this.name,
    required this.isDirectory,
    this.children = const [],
  });

  /// Creates a copy of this FileNode with updated fields
  FileNode copyWith({
    String? path,
    String? name,
    bool? isDirectory,
    List<FileNode>? children,
  }) {
    return FileNode(
      path: path ?? this.path,
      name: name ?? this.name,
      isDirectory: isDirectory ?? this.isDirectory,
      children: children ?? this.children,
    );
  }

  /// Returns all markdown files in this node and its children (recursive)
  List<FileNode> getAllMarkdownFiles() {
    final List<FileNode> files = [];

    if (!isDirectory && name.endsWith('.md')) {
      files.add(this);
    }

    for (final child in children) {
      files.addAll(child.getAllMarkdownFiles());
    }

    return files;
  }

  /// Finds a node by path (recursive search)
  FileNode? findByPath(String searchPath) {
    if (path == searchPath) {
      return this;
    }

    for (final child in children) {
      final found = child.findByPath(searchPath);
      if (found != null) {
        return found;
      }
    }

    return null;
  }

  /// Returns the depth of this node in the tree
  int get depth {
    return path.split('/').where((s) => s.isNotEmpty).length;
  }

  @override
  List<Object?> get props => [path, name, isDirectory, children];

  @override
  String toString() {
    return 'FileNode(path: $path, name: $name, isDirectory: $isDirectory, children: ${children.length})';
  }
}
