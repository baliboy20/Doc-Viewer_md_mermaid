import 'package:equatable/equatable.dart';

/// Represents an annotation (sticky note) attached to a specific location in a markdown document
class Annotation extends Equatable {
  /// Unique identifier for the annotation
  final String id;

  /// The file path this annotation belongs to
  final String filePath;

  /// Text snippet that anchors this annotation (e.g., "## Prerequisites")
  final String anchorText;

  /// Line number where the anchor appears (1-indexed)
  final int? lineNumber;

  /// Element index in the markdown document (0-indexed)
  /// This identifies which block element (heading, paragraph, etc.) contains this annotation
  final int? elementIndex;

  /// The actual note content
  final String content;

  /// Visual highlight color: yellow, red, blue, green, orange, purple
  final String color;

  /// When this annotation was created
  final DateTime createdAt;

  /// When this annotation was last updated
  final DateTime? updatedAt;

  /// Optional tags for categorization
  final List<String> tags;

  const Annotation({
    required this.id,
    required this.filePath,
    required this.anchorText,
    this.lineNumber,
    this.elementIndex,
    required this.content,
    this.color = 'yellow',
    required this.createdAt,
    this.updatedAt,
    this.tags = const [],
  });

  /// Creates a copy with updated fields
  Annotation copyWith({
    String? id,
    String? filePath,
    String? anchorText,
    int? lineNumber,
    int? elementIndex,
    String? content,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return Annotation(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      anchorText: anchorText ?? this.anchorText,
      lineNumber: lineNumber ?? this.lineNumber,
      elementIndex: elementIndex ?? this.elementIndex,
      content: content ?? this.content,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        filePath,
        anchorText,
        lineNumber,
        elementIndex,
        content,
        color,
        createdAt,
        updatedAt,
        tags,
      ];

  @override
  String toString() {
    return 'Annotation(id: $id, anchor: $anchorText, element: $elementIndex, color: $color)';
  }
}
