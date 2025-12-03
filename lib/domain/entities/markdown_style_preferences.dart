import 'package:equatable/equatable.dart';

/// User preferences for markdown rendering styles
class MarkdownStylePreferences extends Equatable {
  final double baseFontSize;
  final double h1FontSize;
  final double codeFontSize;
  final double lineHeight;
  final double hrThickness;
  final bool showCodeLineNumbers;
  final bool enableSyntaxHighlighting;

  const MarkdownStylePreferences({
    this.baseFontSize = 15.0,
    this.h1FontSize = 32.0,
    this.codeFontSize = 14.0,
    this.lineHeight = 1.6,
    this.hrThickness = 0.5,
    this.showCodeLineNumbers = false,
    this.enableSyntaxHighlighting = true,
  });

  /// Creates a copy with updated fields
  MarkdownStylePreferences copyWith({
    double? baseFontSize,
    double? h1FontSize,
    double? codeFontSize,
    double? lineHeight,
    double? hrThickness,
    bool? showCodeLineNumbers,
    bool? enableSyntaxHighlighting,
  }) {
    return MarkdownStylePreferences(
      baseFontSize: baseFontSize ?? this.baseFontSize,
      h1FontSize: h1FontSize ?? this.h1FontSize,
      codeFontSize: codeFontSize ?? this.codeFontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      hrThickness: hrThickness ?? this.hrThickness,
      showCodeLineNumbers: showCodeLineNumbers ?? this.showCodeLineNumbers,
      enableSyntaxHighlighting: enableSyntaxHighlighting ?? this.enableSyntaxHighlighting,
    );
  }

  /// Converts to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'baseFontSize': baseFontSize,
      'h1FontSize': h1FontSize,
      'codeFontSize': codeFontSize,
      'lineHeight': lineHeight,
      'hrThickness': hrThickness,
      'showCodeLineNumbers': showCodeLineNumbers,
      'enableSyntaxHighlighting': enableSyntaxHighlighting,
    };
  }

  /// Creates from JSON
  factory MarkdownStylePreferences.fromJson(Map<String, dynamic> json) {
    return MarkdownStylePreferences(
      baseFontSize: (json['baseFontSize'] as num?)?.toDouble() ?? 15.0,
      h1FontSize: (json['h1FontSize'] as num?)?.toDouble() ?? 32.0,
      codeFontSize: (json['codeFontSize'] as num?)?.toDouble() ?? 14.0,
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.6,
      hrThickness: (json['hrThickness'] as num?)?.toDouble() ?? 0.5,
      showCodeLineNumbers: json['showCodeLineNumbers'] as bool? ?? false,
      enableSyntaxHighlighting: json['enableSyntaxHighlighting'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        baseFontSize,
        h1FontSize,
        codeFontSize,
        lineHeight,
        hrThickness,
        showCodeLineNumbers,
        enableSyntaxHighlighting,
      ];

  @override
  String toString() {
    return 'MarkdownStylePreferences(baseFontSize: $baseFontSize, codeFontSize: $codeFontSize, lineHeight: $lineHeight)';
  }
}
