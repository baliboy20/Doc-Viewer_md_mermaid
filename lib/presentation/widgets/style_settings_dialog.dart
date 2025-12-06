import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/markdown_style_preferences.dart';
import 'package:doc_viewer_app/core/theme/seez_theme.dart';

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

class _StyleSettingsDialogState extends State<StyleSettingsDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Font sizes
  late double _baseFontSize;
  late double _h1FontSize;
  late double _h2FontSize;
  late double _h3FontSize;
  late double _h4FontSize;
  late double _h5FontSize;
  late double _h6FontSize;
  late double _codeFontSize;
  late double _blockquoteFontSize;

  // Spacing
  late double _lineHeight;
  late double _paragraphSpacing;
  late double _headingSpacing;
  late double _listIndent;
  late double _blockquoteIndent;

  // Visual elements
  late double _hrThickness;
  late double _codeBlockPadding;
  late double _blockquoteBorderWidth;

  // Toggles
  late bool _showCodeLineNumbers;
  late bool _enableSyntaxHighlighting;
  late bool _boldHeadings;
  late bool _underlineLinks;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCurrentStyles();
  }

  void _loadCurrentStyles() {
    _baseFontSize = widget.currentStyles.baseFontSize;
    _h1FontSize = widget.currentStyles.h1FontSize;
    _h2FontSize = widget.currentStyles.h2FontSize;
    _h3FontSize = widget.currentStyles.h3FontSize;
    _h4FontSize = widget.currentStyles.h4FontSize;
    _h5FontSize = widget.currentStyles.h5FontSize;
    _h6FontSize = widget.currentStyles.h6FontSize;
    _codeFontSize = widget.currentStyles.codeFontSize;
    _blockquoteFontSize = widget.currentStyles.blockquoteFontSize;
    _lineHeight = widget.currentStyles.lineHeight;
    _paragraphSpacing = widget.currentStyles.paragraphSpacing;
    _headingSpacing = widget.currentStyles.headingSpacing;
    _listIndent = widget.currentStyles.listIndent;
    _blockquoteIndent = widget.currentStyles.blockquoteIndent;
    _hrThickness = widget.currentStyles.hrThickness;
    _codeBlockPadding = widget.currentStyles.codeBlockPadding;
    _blockquoteBorderWidth = widget.currentStyles.blockquoteBorderWidth;
    _showCodeLineNumbers = widget.currentStyles.showCodeLineNumbers;
    _enableSyntaxHighlighting = widget.currentStyles.enableSyntaxHighlighting;
    _boldHeadings = widget.currentStyles.boldHeadings;
    _underlineLinks = widget.currentStyles.underlineLinks;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _applyChanges() {
    final newStyles = MarkdownStylePreferences(
      baseFontSize: _baseFontSize,
      h1FontSize: _h1FontSize,
      h2FontSize: _h2FontSize,
      h3FontSize: _h3FontSize,
      h4FontSize: _h4FontSize,
      h5FontSize: _h5FontSize,
      h6FontSize: _h6FontSize,
      codeFontSize: _codeFontSize,
      blockquoteFontSize: _blockquoteFontSize,
      lineHeight: _lineHeight,
      paragraphSpacing: _paragraphSpacing,
      headingSpacing: _headingSpacing,
      listIndent: _listIndent,
      blockquoteIndent: _blockquoteIndent,
      hrThickness: _hrThickness,
      codeBlockPadding: _codeBlockPadding,
      blockquoteBorderWidth: _blockquoteBorderWidth,
      showCodeLineNumbers: _showCodeLineNumbers,
      enableSyntaxHighlighting: _enableSyntaxHighlighting,
      boldHeadings: _boldHeadings,
      underlineLinks: _underlineLinks,
    );

    widget.onStylesChanged(newStyles);
    Navigator.of(context).pop();
  }

  void _resetToDefaults() {
    setState(() {
      _baseFontSize = 15.0;
      _h1FontSize = 32.0;
      _h2FontSize = 28.0;
      _h3FontSize = 24.0;
      _h4FontSize = 20.0;
      _h5FontSize = 17.0;
      _h6FontSize = 15.0;
      _codeFontSize = 14.0;
      _blockquoteFontSize = 15.0;
      _lineHeight = 1.6;
      _paragraphSpacing = 16.0;
      _headingSpacing = 24.0;
      _listIndent = 24.0;
      _blockquoteIndent = 16.0;
      _hrThickness = 0.5;
      _codeBlockPadding = 16.0;
      _blockquoteBorderWidth = 4.0;
      _showCodeLineNumbers = false;
      _enableSyntaxHighlighting = true;
      _boldHeadings = true;
      _underlineLinks = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SeezTheme.borderRadiusMedium),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: SeezTheme.lightBeigeGradient1,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(SeezTheme.borderRadiusMedium),
                  topRight: Radius.circular(SeezTheme.borderRadiusMedium),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: SeezTheme.mediumBrownBorder,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
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
            ),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: SeezTheme.parchmentBackground,
                border: Border(
                  bottom: BorderSide(
                    color: SeezTheme.mediumBrownBorder,
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: SeezTheme.primaryBrown,
                unselectedLabelColor: SeezTheme.subtitleBrown,
                indicatorColor: SeezTheme.primaryBrown,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Headings'),
                  Tab(text: 'Text & Code'),
                  Tab(text: 'Spacing'),
                  Tab(text: 'Elements'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildHeadingsTab(),
                  _buildTextCodeTab(),
                  _buildSpacingTab(),
                  _buildElementsTab(),
                ],
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SeezTheme.lightBeigeGradient1,
                border: Border(
                  top: BorderSide(
                    color: SeezTheme.mediumBrownBorder,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
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
                        child: const Text('Apply Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSlider(
            label: 'H1 - Main Heading',
            value: _h1FontSize,
            min: 24.0,
            max: 48.0,
            divisions: 24,
            onChanged: (value) => setState(() => _h1FontSize = value),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label: 'H2 - Section Heading',
            value: _h2FontSize,
            min: 20.0,
            max: 40.0,
            divisions: 20,
            onChanged: (value) => setState(() => _h2FontSize = value),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label: 'H3 - Subsection',
            value: _h3FontSize,
            min: 18.0,
            max: 32.0,
            divisions: 14,
            onChanged: (value) => setState(() => _h3FontSize = value),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label: 'H4 - Minor Heading',
            value: _h4FontSize,
            min: 16.0,
            max: 28.0,
            divisions: 12,
            onChanged: (value) => setState(() => _h4FontSize = value),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label: 'H5 - Small Heading',
            value: _h5FontSize,
            min: 14.0,
            max: 24.0,
            divisions: 10,
            onChanged: (value) => setState(() => _h5FontSize = value),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label: 'H6 - Smallest Heading',
            value: _h6FontSize,
            min: 12.0,
            max: 20.0,
            divisions: 8,
            onChanged: (value) => setState(() => _h6FontSize = value),
          ),
          const SizedBox(height: 24),
          _buildSwitchTile(
            title: 'Bold Headings',
            subtitle: 'Make all headings bold',
            value: _boldHeadings,
            onChanged: (value) => setState(() => _boldHeadings = value),
          ),
        ],
      ),
    );
  }

  Widget _buildTextCodeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSlider(
            label: 'Body Text Size',
            value: _baseFontSize,
            min: 12.0,
            max: 24.0,
            divisions: 12,
            onChanged: (value) => setState(() => _baseFontSize = value),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label: 'Code Font Size',
            value: _codeFontSize,
            min: 10.0,
            max: 20.0,
            divisions: 10,
            onChanged: (value) => setState(() => _codeFontSize = value),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label: 'Blockquote Font Size',
            value: _blockquoteFontSize,
            min: 12.0,
            max: 22.0,
            divisions: 10,
            onChanged: (value) => setState(() => _blockquoteFontSize = value),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label: 'Line Height',
            value: _lineHeight,
            min: 1.2,
            max: 2.4,
            divisions: 12,
            onChanged: (value) => setState(() => _lineHeight = value),
          ),
          const SizedBox(height: 24),
          _buildSwitchTile(
            title: 'Syntax Highlighting',
            subtitle: 'Color-code programming languages in code blocks',
            value: _enableSyntaxHighlighting,
            onChanged: (value) => setState(() => _enableSyntaxHighlighting = value),
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            title: 'Code Line Numbers',
            subtitle: 'Show line numbers in code blocks',
            value: _showCodeLineNumbers,
            onChanged: (value) => setState(() => _showCodeLineNumbers = value),
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            title: 'Underline Links',
            subtitle: 'Add underline to hyperlinks',
            value: _underlineLinks,
            onChanged: (value) => setState(() => _underlineLinks = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSlider(
            label: 'Paragraph Spacing',
            value: _paragraphSpacing,
            min: 8.0,
            max: 32.0,
            divisions: 24,
            onChanged: (value) => setState(() => _paragraphSpacing = value),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label: 'Heading Spacing',
            value: _headingSpacing,
            min: 12.0,
            max: 48.0,
            divisions: 36,
            onChanged: (value) => setState(() => _headingSpacing = value),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label: 'List Indent',
            value: _listIndent,
            min: 12.0,
            max: 48.0,
            divisions: 36,
            onChanged: (value) => setState(() => _listIndent = value),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label: 'Blockquote Indent',
            value: _blockquoteIndent,
            min: 8.0,
            max: 40.0,
            divisions: 32,
            onChanged: (value) => setState(() => _blockquoteIndent = value),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label: 'Code Block Padding',
            value: _codeBlockPadding,
            min: 8.0,
            max: 32.0,
            divisions: 24,
            onChanged: (value) => setState(() => _codeBlockPadding = value),
          ),
        ],
      ),
    );
  }

  Widget _buildElementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSlider(
            label: 'Separator Line Thickness',
            value: _hrThickness,
            min: 0.25,
            max: 4.0,
            divisions: 15,
            onChanged: (value) => setState(() => _hrThickness = value),
          ),
          const SizedBox(height: 20),
          _buildSlider(
            label: 'Blockquote Border Width',
            value: _blockquoteBorderWidth,
            min: 1.0,
            max: 8.0,
            divisions: 7,
            onChanged: (value) => setState(() => _blockquoteBorderWidth = value),
          ),
        ],
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
