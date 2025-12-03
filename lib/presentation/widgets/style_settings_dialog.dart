import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/markdown_style_preferences.dart';
import '../theme/seez_theme.dart';

/// Dialog for customizing markdown rendering preferences
class StyleSettingsDialog extends StatefulWidget {
  final MarkdownStylePreferences currentStyles;
  final Function(MarkdownStylePreferences) onStylesChanged;

  const StyleSettingsDialog({
    super.key,
    required this.currentStyles,
    required this.onStylesChanged,
  });

  @override
  State<StyleSettingsDialog> createState() => _StyleSettingsDialogState();
}

class _StyleSettingsDialogState extends State<StyleSettingsDialog> {
  late double _baseFontSize;
  late double _h1FontSize;
  late double _codeFontSize;
  late double _lineHeight;
  late double _hrThickness;
  late bool _showCodeLineNumbers;
  late bool _enableSyntaxHighlighting;

  @override
  void initState() {
    super.initState();
    _baseFontSize = widget.currentStyles.baseFontSize;
    _h1FontSize = widget.currentStyles.h1FontSize;
    _codeFontSize = widget.currentStyles.codeFontSize;
    _lineHeight = widget.currentStyles.lineHeight;
    _hrThickness = widget.currentStyles.hrThickness;
    _showCodeLineNumbers = widget.currentStyles.showCodeLineNumbers;
    _enableSyntaxHighlighting = widget.currentStyles.enableSyntaxHighlighting;
  }

  void _applyChanges() {
    final newStyles = MarkdownStylePreferences(
      baseFontSize: _baseFontSize,
      h1FontSize: _h1FontSize,
      codeFontSize: _codeFontSize,
      lineHeight: _lineHeight,
      hrThickness: _hrThickness,
      showCodeLineNumbers: _showCodeLineNumbers,
      enableSyntaxHighlighting: _enableSyntaxHighlighting,
    );

    widget.onStylesChanged(newStyles);
    Navigator.of(context).pop();
  }

  void _resetToDefaults() {
    setState(() {
      _baseFontSize = 15.0;
      _h1FontSize = 32.0;
      _codeFontSize = 14.0;
      _lineHeight = 1.6;
      _hrThickness = 0.5;
      _showCodeLineNumbers = false;
      _enableSyntaxHighlighting = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SeezTheme.borderRadiusMedium),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  CupertinoIcons.slider_horizontal_3,
                  color: SeezTheme.primaryBrown,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Markdown Style Settings',
                  style: SeezTheme.pageHeaderTitle.copyWith(fontSize: 22),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // H1 Font Size Slider
            _buildSlider(
              label: 'H1 Heading Size',
              value: _h1FontSize,
              min: 24.0,
              max: 48.0,
              divisions: 24,
              onChanged: (value) => setState(() => _h1FontSize = value),
            ),

            const SizedBox(height: 20),

            // Base Font Size Slider
            _buildSlider(
              label: 'Body Text Size',
              value: _baseFontSize,
              min: 12.0,
              max: 24.0,
              divisions: 12,
              onChanged: (value) => setState(() => _baseFontSize = value),
            ),

            const SizedBox(height: 20),

            // Code Font Size Slider
            _buildSlider(
              label: 'Code Font Size',
              value: _codeFontSize,
              min: 10.0,
              max: 20.0,
              divisions: 10,
              onChanged: (value) => setState(() => _codeFontSize = value),
            ),

            const SizedBox(height: 20),

            // Line Height Slider
            _buildSlider(
              label: 'Line Height',
              value: _lineHeight,
              min: 1.2,
              max: 2.4,
              divisions: 12,
              onChanged: (value) => setState(() => _lineHeight = value),
            ),

            const SizedBox(height: 20),

            // Horizontal Rule Thickness Slider
            _buildSlider(
              label: 'Separator Thickness',
              value: _hrThickness,
              min: 0.25,
              max: 3.0,
              divisions: 11,
              onChanged: (value) => setState(() => _hrThickness = value),
            ),

            const SizedBox(height: 24),

            const Divider(),

            const SizedBox(height: 16),

            // Code Line Numbers Toggle
            _buildSwitchTile(
              title: 'Show Code Line Numbers',
              subtitle: 'Display line numbers in code blocks',
              value: _showCodeLineNumbers,
              onChanged: (value) => setState(() => _showCodeLineNumbers = value),
            ),

            const SizedBox(height: 12),

            // Syntax Highlighting Toggle
            _buildSwitchTile(
              title: 'Enable Syntax Highlighting',
              subtitle: 'Color-code programming languages',
              value: _enableSyntaxHighlighting,
              onChanged: (value) => setState(() => _enableSyntaxHighlighting = value),
            ),

            const SizedBox(height: 24),

            const Divider(),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Reset Button
                TextButton.icon(
                  onPressed: _resetToDefaults,
                  icon: const Icon(CupertinoIcons.refresh, size: 18),
                  label: const Text('Reset to Defaults'),
                  style: TextButton.styleFrom(
                    foregroundColor: SeezTheme.subtitleBrown,
                  ),
                ),

                Row(
                  children: [
                    // Cancel Button
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                      style: TextButton.styleFrom(
                        foregroundColor: SeezTheme.subtitleBrown,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Apply Button
                    ElevatedButton(
                      onPressed: _applyChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SeezTheme.primaryBrown,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: SeezTheme.darkBrownText,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: SeezTheme.lightBeigeGradient2,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: SeezTheme.mediumBrownBorder,
                  width: 1,
                ),
              ),
              child: Text(
                value.toStringAsFixed(1),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: SeezTheme.primaryBrown,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: SeezTheme.primaryBrown,
            inactiveTrackColor: SeezTheme.mediumBrownBorder.withOpacity(0.3),
            thumbColor: SeezTheme.primaryBrown,
            overlayColor: SeezTheme.primaryBrown.withOpacity(0.2),
            valueIndicatorColor: SeezTheme.primaryBrown,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SeezTheme.lightCreamTile,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: SeezTheme.mediumBrownBorder.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: SeezTheme.darkBrownText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: SeezTheme.subtitleBrown,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return SeezTheme.primaryBrown;
              }
              return null;
            }),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return SeezTheme.primaryBrown.withValues(alpha: 0.5);
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }
}
