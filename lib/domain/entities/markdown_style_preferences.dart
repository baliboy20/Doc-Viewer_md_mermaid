import 'package:equatable/equatable.dart';

/// User preferences for markdown rendering styles
class MarkdownStylePreferences extends Equatable {
  // Font sizes
  final double baseFontSize;
  final double h1FontSize;
  final double h2FontSize;
  final double h3FontSize;
  final double h4FontSize;
  final double h5FontSize;
  final double h6FontSize;
  final double codeFontSize;
  final double blockquoteFontSize;

  // Spacing
  final double lineHeight;
  final double paragraphSpacing;
  final double headingSpacing;
  final double listIndent;
  final double blockquoteIndent;

  // Visual elements
  final double hrThickness;
  final double codeBlockPadding;
  final double blockquoteBorderWidth;

  // Toggles
  final bool showCodeLineNumbers;
  final bool enableSyntaxHighlighting;
  final bool boldHeadings;
  final bool underlineLinks;

  const MarkdownStylePreferences({
    // Font sizes
    this.baseFontSize = 15.0,
    this.h1FontSize = 32.0,
    this.h2FontSize = 28.0,
    this.h3FontSize = 24.0,
    this.h4FontSize = 20.0,
    this.h5FontSize = 17.0,
    this.h6FontSize = 15.0,
    this.codeFontSize = 14.0,
    this.blockquoteFontSize = 15.0,

    // Spacing
    this.lineHeight = 1.6,
    this.paragraphSpacing = 16.0,
    this.headingSpacing = 24.0,
    this.listIndent = 24.0,
    this.blockquoteIndent = 16.0,

    // Visual elements
    this.hrThickness = 0.5,
    this.codeBlockPadding = 16.0,
    this.blockquoteBorderWidth = 4.0,

    // Toggles
    this.showCodeLineNumbers = false,
    this.enableSyntaxHighlighting = true,
    this.boldHeadings = true,
    this.underlineLinks = false,
  });

  /// Creates a copy with updated fields
  MarkdownStylePreferences copyWith({
    double? baseFontSize,
    double? h1FontSize,
    double? h2FontSize,
    double? h3FontSize,
    double? h4FontSize,
    double? h5FontSize,
    double? h6FontSize,
    double? codeFontSize,
    double? blockquoteFontSize,
    double? lineHeight,
    double? paragraphSpacing,
    double? headingSpacing,
    double? listIndent,
    double? blockquoteIndent,
    double? hrThickness,
    double? codeBlockPadding,
    double? blockquoteBorderWidth,
    bool? showCodeLineNumbers,
    bool? enableSyntaxHighlighting,
    bool? boldHeadings,
    bool? underlineLinks,
  }) {
    return MarkdownStylePreferences(
      baseFontSize: baseFontSize ?? this.baseFontSize,
      h1FontSize: h1FontSize ?? this.h1FontSize,
      h2FontSize: h2FontSize ?? this.h2FontSize,
      h3FontSize: h3FontSize ?? this.h3FontSize,
      h4FontSize: h4FontSize ?? this.h4FontSize,
      h5FontSize: h5FontSize ?? this.h5FontSize,
      h6FontSize: h6FontSize ?? this.h6FontSize,
      codeFontSize: codeFontSize ?? this.codeFontSize,
      blockquoteFontSize: blockquoteFontSize ?? this.blockquoteFontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      paragraphSpacing: paragraphSpacing ?? this.paragraphSpacing,
      headingSpacing: headingSpacing ?? this.headingSpacing,
      listIndent: listIndent ?? this.listIndent,
      blockquoteIndent: blockquoteIndent ?? this.blockquoteIndent,
      hrThickness: hrThickness ?? this.hrThickness,
      codeBlockPadding: codeBlockPadding ?? this.codeBlockPadding,
      blockquoteBorderWidth: blockquoteBorderWidth ?? this.blockquoteBorderWidth,
      showCodeLineNumbers: showCodeLineNumbers ?? this.showCodeLineNumbers,
      enableSyntaxHighlighting: enableSyntaxHighlighting ?? this.enableSyntaxHighlighting,
      boldHeadings: boldHeadings ?? this.boldHeadings,
      underlineLinks: underlineLinks ?? this.underlineLinks,
    );
  }

  /// Converts to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'baseFontSize': baseFontSize,
      'h1FontSize': h1FontSize,
      'h2FontSize': h2FontSize,
      'h3FontSize': h3FontSize,
      'h4FontSize': h4FontSize,
      'h5FontSize': h5FontSize,
      'h6FontSize': h6FontSize,
      'codeFontSize': codeFontSize,
      'blockquoteFontSize': blockquoteFontSize,
      'lineHeight': lineHeight,
      'paragraphSpacing': paragraphSpacing,
      'headingSpacing': headingSpacing,
      'listIndent': listIndent,
      'blockquoteIndent': blockquoteIndent,
      'hrThickness': hrThickness,
      'codeBlockPadding': codeBlockPadding,
      'blockquoteBorderWidth': blockquoteBorderWidth,
      'showCodeLineNumbers': showCodeLineNumbers,
      'enableSyntaxHighlighting': enableSyntaxHighlighting,
      'boldHeadings': boldHeadings,
      'underlineLinks': underlineLinks,
    };
  }

  /// Creates from JSON
  factory MarkdownStylePreferences.fromJson(Map<String, dynamic> json) {
    return MarkdownStylePreferences(
      baseFontSize: (json['baseFontSize'] as num?)?.toDouble() ?? 15.0,
      h1FontSize: (json['h1FontSize'] as num?)?.toDouble() ?? 32.0,
      h2FontSize: (json['h2FontSize'] as num?)?.toDouble() ?? 28.0,
      h3FontSize: (json['h3FontSize'] as num?)?.toDouble() ?? 24.0,
      h4FontSize: (json['h4FontSize'] as num?)?.toDouble() ?? 20.0,
      h5FontSize: (json['h5FontSize'] as num?)?.toDouble() ?? 17.0,
      h6FontSize: (json['h6FontSize'] as num?)?.toDouble() ?? 15.0,
      codeFontSize: (json['codeFontSize'] as num?)?.toDouble() ?? 14.0,
      blockquoteFontSize: (json['blockquoteFontSize'] as num?)?.toDouble() ?? 15.0,
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.6,
      paragraphSpacing: (json['paragraphSpacing'] as num?)?.toDouble() ?? 16.0,
      headingSpacing: (json['headingSpacing'] as num?)?.toDouble() ?? 24.0,
      listIndent: (json['listIndent'] as num?)?.toDouble() ?? 24.0,
      blockquoteIndent: (json['blockquoteIndent'] as num?)?.toDouble() ?? 16.0,
      hrThickness: (json['hrThickness'] as num?)?.toDouble() ?? 0.5,
      codeBlockPadding: (json['codeBlockPadding'] as num?)?.toDouble() ?? 16.0,
      blockquoteBorderWidth: (json['blockquoteBorderWidth'] as num?)?.toDouble() ?? 4.0,
      showCodeLineNumbers: json['showCodeLineNumbers'] as bool? ?? false,
      enableSyntaxHighlighting: json['enableSyntaxHighlighting'] as bool? ?? true,
      boldHeadings: json['boldHeadings'] as bool? ?? true,
      underlineLinks: json['underlineLinks'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        baseFontSize,
        h1FontSize,
        h2FontSize,
        h3FontSize,
        h4FontSize,
        h5FontSize,
        h6FontSize,
        codeFontSize,
        blockquoteFontSize,
        lineHeight,
        paragraphSpacing,
        headingSpacing,
        listIndent,
        blockquoteIndent,
        hrThickness,
        codeBlockPadding,
        blockquoteBorderWidth,
        showCodeLineNumbers,
        enableSyntaxHighlighting,
        boldHeadings,
        underlineLinks,
      ];

  @override
  String toString() {
    return 'MarkdownStylePreferences(baseFontSize: $baseFontSize, codeFontSize: $codeFontSize, lineHeight: $lineHeight)';
  }
}
