import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/markdown_style_preferences.dart';
import 'app_logger.dart';

/// Service for managing user preferences
class PreferencesService {
  static const String _keyTheme = 'theme';
  static const String _keyMarkdownStyles = 'markdown_styles';
  static const String _keyLastFolder = 'last_folder';

  /// Gets the saved theme
  Future<String> getTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyTheme) ?? 'seez';
    } catch (e) {
      AppLogger.error('Error getting theme', tag: 'Preferences', error: e);
      return 'seez';
    }
  }

  /// Sets the theme
  Future<void> setTheme(String theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyTheme, theme);
      AppLogger.debug('Theme saved', tag: 'Preferences', data: theme);
    } catch (e) {
      AppLogger.error('Error setting theme', tag: 'Preferences', error: e);
    }
  }

  /// Gets the saved markdown styles
  Future<MarkdownStylePreferences> getMarkdownStyles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyMarkdownStyles);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return MarkdownStylePreferences.fromJson(json);
      }

      return const MarkdownStylePreferences();
    } catch (e) {
      AppLogger.error('Error getting markdown styles', tag: 'Preferences', error: e);
      return const MarkdownStylePreferences();
    }
  }

  /// Sets the markdown styles
  Future<void> setMarkdownStyles(MarkdownStylePreferences styles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(styles.toJson());
      await prefs.setString(_keyMarkdownStyles, jsonString);
      AppLogger.debug('Markdown styles saved', tag: 'Preferences');
    } catch (e) {
      AppLogger.error('Error setting markdown styles', tag: 'Preferences', error: e);
    }
  }

  /// Gets the last opened folder path
  Future<String?> getLastFolder() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyLastFolder);
    } catch (e) {
      AppLogger.error('Error getting last folder', tag: 'Preferences', error: e);
      return null;
    }
  }

  /// Sets the last opened folder path
  Future<void> setLastFolder(String folderPath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLastFolder, folderPath);
      AppLogger.debug('Last folder saved', tag: 'Preferences', data: folderPath);
    } catch (e) {
      AppLogger.error('Error setting last folder', tag: 'Preferences', error: e);
    }
  }

  /// Clears all preferences
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      AppLogger.info('All preferences cleared', tag: 'Preferences');
    } catch (e) {
      AppLogger.error('Error clearing preferences', tag: 'Preferences', error: e);
    }
  }
}
