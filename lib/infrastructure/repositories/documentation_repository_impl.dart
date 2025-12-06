import 'package:doc_viewer_app/features/documentation/domain/entities/file_node.dart';
import 'package:doc_viewer_app/features/documentation/domain/repositories/documentation_repository.dart';
import '../datasources/filesystem_documentation_datasource.dart';

/// Implementation of DocumentationRepository using filesystem datasource
class DocumentationRepositoryImpl implements DocumentationRepository {
  final FilesystemDocumentationDatasource datasource;

  DocumentationRepositoryImpl({
    required this.datasource,
  });

  @override
  Future<List<FileNode>> loadFileTree() async {
    try {
      return await datasource.loadFileTree();
    } catch (e) {
      throw Exception('Repository: Failed to load file tree - $e');
    }
  }

  @override
  Future<String> readFileContent(String filePath) async {
    try {
      return await datasource.readFileContent(filePath);
    } catch (e) {
      throw Exception('Repository: Failed to read file content - $e');
    }
  }

  @override
  Future<List<FileNode>> searchFiles(String query) async {
    try {
      return await datasource.searchFiles(query);
    } catch (e) {
      throw Exception('Repository: Failed to search files - $e');
    }
  }

  @override
  Future<bool> exists(String path) async {
    try {
      return await datasource.exists(path);
    } catch (e) {
      return false;
    }
  }

  @override
  String getRootPath() {
    return datasource.docsRootPath;
  }
}
