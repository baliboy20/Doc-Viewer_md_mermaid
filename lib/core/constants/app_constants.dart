/// Application-wide constants
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // App Info
  static const String appName = 'Rome Doc Viewer';
  static const String appVersion = '1.6.0';
  static const String appCodeName = 'Nassau';

  // File Extensions
  static const List<String> supportedMarkdownExtensions = ['.md', '.markdown'];

  // Default Values for Markdown Styling
  static const double defaultBaseFontSize = 16.0;
  static const double defaultCodeFontSize = 14.0;
  static const double defaultHrThickness = 1.0;
  static const double defaultH1FontSize = 32.0;

  // Annotation Colors
  static const List<String> annotationColors = [
    'yellow',
    'blue',
    'green',
    'orange',
    'pink',
    'purple',
  ];

  // Preferences Keys
  static const String prefKeyTheme = 'theme';
  static const String prefKeyMarkdownStyles = 'markdown_styles';
  static const String prefKeyLastOpenedPath = 'last_opened_path';

  // UI Constants
  static const double defaultScrollAdjustment = 80.0;
  static const double annotationBadgeSize = 14.0;
  static const int scrollAnimationDuration = 500; // milliseconds
}
