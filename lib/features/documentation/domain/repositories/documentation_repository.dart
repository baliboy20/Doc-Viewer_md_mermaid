import '../entities/file_node.dart';

/// Repository interface for documentation operations
/// Defines the contract for accessing documentation files and content
abstract class DocumentationRepository {
  /// Loads the file tree from the documentation root directory
  /// Returns a list of FileNode objects representing the directory structure
  /// Throws an exception if the directory cannot be read
  Future<List<FileNode>> loadFileTree();

  /// Reads the content of a file at the given path
  /// Returns the file content as a string
  /// Throws an exception if the file cannot be read
  Future<String> readFileContent(String filePath);

  /// Searches for files matching the given query
  /// Returns a list of FileNode objects that match the search criteria
  Future<List<FileNode>> searchFiles(String query);

  /// Checks if a file or directory exists at the given path
  Future<bool> exists(String path);

  /// Gets the root path of the documentation directory
  String getRootPath();
}
