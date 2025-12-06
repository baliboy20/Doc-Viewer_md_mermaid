import 'dart:io';
import '../../domain/entities/file_node.dart';
import 'package:doc_viewer_app/core/utils/app_logger.dart';

/// Data source for reading documentation files from the file system
class FilesystemDocumentationDatasource {
  final String docsRootPath;

  FilesystemDocumentationDatasource({
    required this.docsRootPath,
  });

  /// Loads the file tree structure from the root directory
  /// Includes both .md (markdown) and .mermaid (diagram) files
  Future<List<FileNode>> loadFileTree() async {
    try {
      final rootDir = Directory(docsRootPath);

      if (!rootDir.existsSync()) {
        AppLogger.error('Documentation directory does not exist', tag: 'Datasource', data: docsRootPath);
        throw Exception('Documentation directory does not exist: $docsRootPath');
      }

      AppLogger.info('Loading file tree', tag: 'Datasource', data: docsRootPath);

      final entities = rootDir.listSync()
        ..sort((a, b) {
          // Sort directories first, then files
          final aIsDir = a is Directory;
          final bIsDir = b is Directory;

          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;

          // Then sort alphabetically
          return a.path.toLowerCase().compareTo(b.path.toLowerCase());
        });

      final fileNodes = <FileNode>[];

      for (final entity in entities) {
        final node = await _buildFileNode(entity);
        if (node != null) {
          fileNodes.add(node);
        }
      }

      return fileNodes;
    } catch (e) {
      throw Exception('Failed to load file tree: $e');
    }
  }

  /// Recursively builds a FileNode from a file system entity
  Future<FileNode?> _buildFileNode(FileSystemEntity entity) async {
    try {
      final name = entity.path.split('/').last;

      // Skip hidden files and directories
      if (name.startsWith('.')) {
        return null;
      }

      if (entity is Directory) {
        // Build directory node
        try {
          final children = <FileNode>[];
          final entities = entity.listSync()
            ..sort((a, b) {
              final aIsDir = a is Directory;
              final bIsDir = b is Directory;

              if (aIsDir && !bIsDir) return -1;
              if (!aIsDir && bIsDir) return 1;

              return a.path.toLowerCase().compareTo(b.path.toLowerCase());
            });

          for (final child in entities) {
            final childNode = await _buildFileNode(child);
            if (childNode != null) {
              children.add(childNode);
            }
          }

          // Only include directories that have markdown files (direct or nested)
          if (children.isEmpty) {
            return null;
          }

          return FileNode(
            path: entity.path,
            name: name,
            isDirectory: true,
            children: children,
          );
        } catch (e) {
          // Skip directories we can't read
          AppLogger.warning('Cannot read directory', tag: 'Datasource', data: '$name: $e');
          return null;
        }
      } else if (entity is File) {
        // Include markdown and mermaid files
        if (!name.endsWith('.md') && !name.endsWith('.mermaid')) {
          return null;
        }

        return FileNode(
          path: entity.path,
          name: name,
          isDirectory: false,
          children: const [],
        );
      }

      return null;
    } catch (e) {
      AppLogger.error('Error building node', tag: 'Datasource', error: e, data: entity.path);
      return null;
    }
  }

  /// Reads the content of a file
  Future<String> readFileContent(String filePath) async {
    try {
      final file = File(filePath);

      if (!file.existsSync()) {
        throw Exception('File does not exist: $filePath');
      }

      return await file.readAsString();
    } catch (e) {
      throw Exception('Failed to read file content: $e');
    }
  }

  /// Searches for files matching the query
  Future<List<FileNode>> searchFiles(String query) async {
    try {
      final allNodes = await loadFileTree();
      final results = <FileNode>[];

      void searchRecursive(List<FileNode> nodes) {
        for (final node in nodes) {
          if (node.name.toLowerCase().contains(query.toLowerCase())) {
            results.add(node);
          }

          if (node.isDirectory) {
            searchRecursive(node.children);
          }
        }
      }

      searchRecursive(allNodes);
      return results;
    } catch (e) {
      throw Exception('Failed to search files: $e');
    }
  }

  /// Checks if a path exists
  Future<bool> exists(String path) async {
    try {
      final entity = FileSystemEntity.typeSync(path);
      return entity != FileSystemEntityType.notFound;
    } catch (e) {
      return false;
    }
  }
}
