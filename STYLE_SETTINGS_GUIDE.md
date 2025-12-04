# Markdown Style Settings Guide

## Overview
Florence now provides comprehensive customization of all markdown rendering styles. Users can adjust fonts, spacing, and visual elements to create their perfect reading experience.

## Changes Made

### 1. **Extended MarkdownStylePreferences Entity** (`lib/domain/entities/markdown_style_preferences.dart`)

Added complete control over all markdown elements:

#### Font Sizes (9 total)
- `baseFontSize` - Body text (12-24px, default: 15px)
- `h1FontSize` - Main headings (24-48px, default: 32px)
- `h2FontSize` - Section headings (20-40px, default: 28px)
- `h3FontSize` - Subsections (18-32px, default: 24px)
- `h4FontSize` - Minor headings (16-28px, default: 20px)
- `h5FontSize` - Small headings (14-24px, default: 17px)
- `h6FontSize` - Smallest headings (12-20px, default: 15px)
- `codeFontSize` - Code blocks (10-20px, default: 14px)
- `blockquoteFontSize` - Blockquotes (12-22px, default: 15px)

#### Spacing Controls (5 total)
- `lineHeight` - Line spacing (1.2-2.4x, default: 1.6x)
- `paragraphSpacing` - Space between paragraphs (8-32px, default: 16px)
- `headingSpacing` - Space around headings (12-48px, default: 24px)
- `listIndent` - List item indentation (12-48px, default: 24px)
- `blockquoteIndent` - Blockquote left indent (8-40px, default: 16px)

#### Visual Elements (3 total)
- `hrThickness` - Horizontal rule thickness (0.25-4px, default: 0.5px)
- `codeBlockPadding` - Padding inside code blocks (8-32px, default: 16px)
- `blockquoteBorderWidth` - Blockquote left border (1-8px, default: 4px)

#### Toggles (4 total)
- `showCodeLineNumbers` - Display line numbers in code blocks (default: false)
- `enableSyntaxHighlighting` - Color-code programming languages (default: true)
- `boldHeadings` - Make all headings bold (default: true)
- `underlineLinks` - Add underline to hyperlinks (default: false)

### 2. **Enhanced Style Settings Dialog** (`lib/presentation/widgets/style_settings_dialog.dart`)

Complete redesign with tabbed interface for better organization:

#### Four Organized Tabs:

**Headings Tab**
- Individual size controls for H1-H6
- Bold headings toggle
- Clear labels for each heading level

**Text & Code Tab**
- Body text size
- Code font size
- Blockquote font size
- Line height
- Syntax highlighting toggle
- Code line numbers toggle
- Underline links toggle

**Spacing Tab**
- Paragraph spacing
- Heading spacing
- List indent
- Blockquote indent
- Code block padding

**Elements Tab**
- Separator line thickness
- Blockquote border width

## User Interface

### Dialog Features
- **Tabbed Navigation** - Organized into 4 clear categories
- **Live Preview Values** - Each slider shows current value
- **Reset to Defaults** - One-click return to default settings
- **Cancel/Apply** - Safe preview before applying changes

### Visual Design
- Seez theme colors throughout
- Clear labels and descriptions
- Responsive sliders with appropriate ranges
- Toggle switches with clear on/off states

## Usage

### Opening Style Settings
Users can access style settings from the documentation viewer toolbar.

### Adjusting Settings
1. Select a tab (Headings, Text & Code, Spacing, or Elements)
2. Use sliders to adjust numeric values
3. Toggle switches for boolean options
4. See live value updates next to each control
5. Click "Apply Changes" to save

### Resetting to Defaults
Click "Reset to Defaults" button at any time to restore factory settings.

## Persistence

All style preferences are automatically saved to local storage and persist between app sessions via the `PreferencesService`.

## Example Use Cases

### Accessibility - Larger Text
```dart
- baseFontSize: 18.0 (increased from 15.0)
- h1FontSize: 40.0 (increased from 32.0)
- lineHeight: 1.8 (increased from 1.6)
```

### Compact Reading
```dart
- paragraphSpacing: 12.0 (decreased from 16.0)
- headingSpacing: 16.0 (decreased from 24.0)
- lineHeight: 1.4 (decreased from 1.6)
```

### Code-Focused
```dart
- codeFontSize: 16.0 (increased from 14.0)
- showCodeLineNumbers: true
- codeBlockPadding: 20.0 (increased from 16.0)
```

### Minimalist
```dart
- hrThickness: 0.25 (decreased from 0.5)
- blockquoteBorderWidth: 2.0 (decreased from 4.0)
- boldHeadings: false
- underlineLinks: false
```

## Technical Details

### Data Flow
1. User adjusts settings in dialog
2. Dialog creates new `MarkdownStylePreferences` object
3. Callback passes new preferences to parent
4. PreferencesService saves to SharedPreferences
5. MarkdownViewer rebuilds with new styles

### JSON Serialization
All preferences are serialized to JSON for storage:
```json
{
  "baseFontSize": 15.0,
  "h1FontSize": 32.0,
  "h2FontSize": 28.0,
  ...
  "boldHeadings": true,
  "underlineLinks": false
}
```

### Backward Compatibility
The `fromJson` factory method provides defaults for all new fields, ensuring existing user preferences continue to work.

## Future Enhancements

Potential additions:
- Custom color themes for syntax highlighting
- Font family selection (serif, sans-serif, monospace)
- Table styling controls
- Image sizing options
- Export/Import preference profiles

## Testing

To test the new settings:

1. Rebuild the app:
   ```bash
   flutter build macos --release
   ```

2. Open Florence and load any markdown document

3. Click the style settings button in the toolbar

4. Experiment with different tabs and settings

5. Verify changes apply correctly to the document

6. Close and reopen the app to verify persistence

## Files Modified

1. `lib/domain/entities/markdown_style_preferences.dart` - Extended entity (21 properties total)
2. `lib/presentation/widgets/style_settings_dialog.dart` - Complete redesign with tabs

## Benefits

✅ Complete control over all markdown elements
✅ Organized, user-friendly interface
✅ Live preview of values
✅ Persistent settings
✅ Backward compatible
✅ Extensible architecture for future additions
