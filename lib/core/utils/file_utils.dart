import 'dart:io';
import '../constants/app_constants.dart';

/// Utility functions for file operations
class FileUtils {
  // Prevent instantiation
  FileUtils._();

  /// Checks if file is a supported markdown file
  static bool isMarkdownFile(String path) {
    return AppConstants.supportedMarkdownExtensions.any(
      (ext) => path.toLowerCase().endsWith(ext),
    );
  }

  /// Gets relative path from root
  ///
  /// Returns the path relative to [rootPath]. If [filePath] doesn't start
  /// with [rootPath], returns [filePath] unchanged.
  static String getRelativePath(String rootPath, String filePath) {
    if (filePath.startsWith(rootPath)) {
      var relative = filePath.substring(rootPath.length);
      // Remove leading slash if present
      if (relative.startsWith('/')) {
        relative = relative.substring(1);
      }
      return relative;
    }
    return filePath;
  }

  /// Checks if file exists
  static Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  /// Checks if directory exists
  static Future<bool> directoryExists(String path) async {
    return Directory(path).exists();
  }

  /// Gets file name from path
  static String getFileName(String path) {
    return path.split(Platform.pathSeparator).last;
  }

  /// Gets directory name from path
  static String getDirectoryName(String path) {
    final parts = path.split(Platform.pathSeparator);
    return parts.length > 1 ? parts[parts.length - 2] : '';
  }

  /// Gets file extension
  static String getFileExtension(String path) {
    final name = getFileName(path);
    final lastDot = name.lastIndexOf('.');
    return lastDot >= 0 ? name.substring(lastDot) : '';
  }
}
