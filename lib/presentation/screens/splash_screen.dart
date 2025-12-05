import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../theme/seez_theme.dart';
import '../../infrastructure/services/app_logger.dart';

/// Splash screen for selecting documentation directory
/// Supports both file picker and manual path entry modes
class SplashScreen extends StatefulWidget {
  final Function(String) onDirectorySelected;

  const SplashScreen({
    super.key,
    required this.onDirectorySelected,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isManualPathMode = false;
  final TextEditingController _pathController = TextEditingController();
  String? _error;
  bool _isLoading = false;
  String _versionInfo = '';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _versionInfo = 'v${packageInfo.version}';
      });
    } catch (e) {
      AppLogger.error('Failed to load version info', tag: 'Splash', error: e);
    }
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  /// Opens native file picker to select a directory
  Future<void> _pickDirectory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Documentation Folder',
      );

      if (selectedDirectory != null) {
        AppLogger.success('Selected directory from picker', tag: 'Splash', data: selectedDirectory);
        widget.onDirectorySelected(selectedDirectory);
      } else {
        AppLogger.info('User cancelled directory selection', tag: 'Splash');
      }
    } catch (e) {
      AppLogger.error('Error picking directory', tag: 'Splash', error: e);
      setState(() {
        _error = 'Failed to open folder picker: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Validates and uses manually entered path
  /// Handles macOS sandbox permissions by opening file picker when needed
  Future<void> _useManualPath() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    var path = _pathController.text.trim();
    AppLogger.info('Attempting to use manual path', tag: 'Splash', data: path);

    // Remove leading colon if present (common typo)
    if (path.startsWith(':')) {
      path = path.substring(1);
      AppLogger.debug('Removed leading colon, new path', tag: 'Splash', data: path);
    }

    if (path.isEmpty) {
      setState(() {
        _error = 'Please enter a folder path';
        _isLoading = false;
      });
      return;
    }

    try {
      final directory = Directory(path);
      AppLogger.debug('Checking if directory exists', tag: 'Splash', data: directory.path);

      if (!directory.existsSync()) {
        AppLogger.warning('Directory does not exist', tag: 'Splash', data: path);
        setState(() {
          _error = 'Directory does not exist: $path';
          _isLoading = false;
        });
        return;
      }

      AppLogger.debug('Directory exists, checking permissions', tag: 'Splash');

      // Try to list directory contents to verify read permissions
      try {
        final contents = directory.listSync();
        AppLogger.success('Successfully listed directory', tag: 'Splash', data: '${contents.length} items');

        // Success! We have permission
        widget.onDirectorySelected(path);

      } catch (permissionError) {
        AppLogger.error('Permission error', tag: 'Splash', error: permissionError);

        // Check if this is a macOS sandbox permission issue
        if (permissionError.toString().contains('Operation not permitted') ||
            permissionError.toString().contains('Permission denied')) {

          AppLogger.warning('Detected macOS permission issue, opening file picker to grant access', tag: 'Splash');

          setState(() {
            _error = 'macOS requires permission to access this folder.\nOpening folder picker to grant access...';
          });

          // Wait a moment for user to see the message
          await Future.delayed(const Duration(milliseconds: 1500));

          // Open file picker with the typed path to allow user to grant permission
          try {
            String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
              dialogTitle: 'Grant Access to: $path',
              initialDirectory: path,
            );

            if (selectedDirectory != null) {
              AppLogger.success('User granted permission via picker', tag: 'Splash', data: selectedDirectory);
              widget.onDirectorySelected(selectedDirectory);
            } else {
              AppLogger.warning('User cancelled permission grant', tag: 'Splash');
              setState(() {
                _error = 'Permission not granted. Please select the folder to grant access.';
                _isLoading = false;
              });
            }
          } catch (pickerError) {
            AppLogger.error('Error opening picker for permission', tag: 'Splash', error: pickerError);
            setState(() {
              _error = 'Failed to open folder picker: $pickerError';
              _isLoading = false;
            });
          }

        } else {
          // Some other error
          AppLogger.error('Unexpected permission error', tag: 'Splash', error: permissionError);
          setState(() {
            _error = 'Cannot read directory: $path\nError: $permissionError';
            _isLoading = false;
          });
        }
      }

    } catch (e) {
      AppLogger.error('Unexpected error in manual path validation', tag: 'Splash', error: e);
      setState(() {
        _error = 'Unexpected error: $e';
        _isLoading = false;
      });
    }
  }

  /// Pastes path from clipboard into text field
  Future<void> _pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData != null && clipboardData.text != null) {
        setState(() {
          _pathController.text = clipboardData.text!;
        });
        AppLogger.debug('Pasted from clipboard', tag: 'Splash', data: clipboardData.text);
      }
    } catch (e) {
      AppLogger.error('Error pasting from clipboard', tag: 'Splash', error: e);
      setState(() {
        _error = 'Failed to paste from clipboard';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SeezTheme.parchmentBackground,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Title
              Text(
                'Rome Doc Viewer',
                style: GoogleFonts.pacifico(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: SeezTheme.primaryBrown,
                  shadows: [
                    const Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Select your documentation folder to begin',
                style: SeezTheme.heroSubtitle,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Error Display
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SeezTheme.dangerLight,
                    borderRadius: BorderRadius.circular(SeezTheme.borderRadiusSmall),
                    border: Border.all(color: SeezTheme.danger, width: 2),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: SeezTheme.danger,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: GoogleFonts.inter(
                            color: SeezTheme.danger,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Manual Path Entry Mode
              if (_isManualPathMode) ...[
                // Path TextField
                TextField(
                  controller: _pathController,
                  decoration: InputDecoration(
                    labelText: 'Folder Path',
                    hintText: '/path/to/your/documentation',
                    prefixIcon: const Icon(Icons.folder_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.content_paste),
                      onPressed: _pasteFromClipboard,
                      tooltip: 'Paste from clipboard',
                    ),
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: SeezTheme.darkBrownText,
                  ),
                  onSubmitted: (_) => _useManualPath(),
                ),

                const SizedBox(height: 16),

                // Use Path Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _useManualPath,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check),
                  label: Text(_isLoading ? 'Validating...' : 'Use This Path'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: SeezTheme.primaryBrown,
                  ),
                ),

                const SizedBox(height: 12),

                // Switch to Picker Button
                TextButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isManualPathMode = false;
                            _error = null;
                          });
                        },
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Use Folder Picker Instead'),
                  style: TextButton.styleFrom(
                    foregroundColor: SeezTheme.primaryBrown,
                  ),
                ),
              ]

              // File Picker Mode (Default)
              else ...[
                // Pick Folder Button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickDirectory,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.folder_open, size: 24),
                  label: Text(
                    _isLoading ? 'Opening...' : 'Choose Folder',
                    style: SeezTheme.buttonText.copyWith(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: SeezTheme.primaryBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SeezTheme.borderRadiusSmall),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Divider with "OR"
                Row(
                  children: [
                    const Expanded(child: Divider(color: SeezTheme.mediumBrownBorder)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: GoogleFonts.inter(
                          color: SeezTheme.subtitleBrown,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: SeezTheme.mediumBrownBorder)),
                  ],
                ),

                const SizedBox(height: 20),

                // Switch to Manual Entry Button
                OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isManualPathMode = true;
                            _error = null;
                          });
                        },
                  icon: const Icon(Icons.edit),
                  label: const Text('Enter Path Manually'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: SeezTheme.primaryBrown,
                    side: const BorderSide(color: SeezTheme.mediumBrownBorder, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SeezTheme.borderRadiusSmall),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 48),

              // Help Text
              Text(
                'Select a folder containing markdown documentation files',
                style: GoogleFonts.inter(
                  color: SeezTheme.subtitleBrown,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Version Info
              if (_versionInfo.isNotEmpty)
                Text(
                  _versionInfo,
                  style: GoogleFonts.inter(
                    color: SeezTheme.subtitleBrown.withOpacity(0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
