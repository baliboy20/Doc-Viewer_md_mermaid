import 'package:flutter/services.dart';
import 'package:doc_viewer_app/core/utils/app_logger.dart';

/// Service for handling macOS menu callbacks via platform channel
class MacOSMenuService {
  static const MethodChannel _channel =
      MethodChannel('com.florence.docs/menu');

  /// Callback function types
  static VoidCallback? onCloneRepository;
  static VoidCallback? onToggleGitPanel;
  static VoidCallback? onGitPull;
  static VoidCallback? onGitPush;
  static VoidCallback? onGitCommit;
  static VoidCallback? onRefreshGitStatus;
  static VoidCallback? onShowHelp;

  /// Initialize the service and set up method call handler
  static void initialize() {
    AppLogger.info('Initializing MacOSMenuService', tag: 'MacOSMenuService');

    _channel.setMethodCallHandler((call) async {
      AppLogger.info(
        'Received method call: ${call.method}',
        tag: 'MacOSMenuService',
      );

      switch (call.method) {
        case 'cloneRepository':
          onCloneRepository?.call();
          break;
        case 'toggleGitPanel':
          onToggleGitPanel?.call();
          break;
        case 'gitPull':
          onGitPull?.call();
          break;
        case 'gitPush':
          onGitPush?.call();
          break;
        case 'gitCommit':
          onGitCommit?.call();
          break;
        case 'refreshGitStatus':
          onRefreshGitStatus?.call();
          break;
        case 'showHelp':
          AppLogger.info('Show help requested', tag: 'MacOSMenuService');
          onShowHelp?.call();
          break;
        default:
          AppLogger.warning(
            'Unknown method call: ${call.method}',
            tag: 'MacOSMenuService',
          );
      }
    });

    AppLogger.success(
      'MacOSMenuService initialized successfully',
      tag: 'MacOSMenuService',
    );
  }

  /// Clean up callbacks
  static void dispose() {
    AppLogger.info('Disposing MacOSMenuService', tag: 'MacOSMenuService');
    onCloneRepository = null;
    onToggleGitPanel = null;
    onGitPull = null;
    onGitPush = null;
    onGitCommit = null;
    onRefreshGitStatus = null;
    onShowHelp = null;
  }
}
