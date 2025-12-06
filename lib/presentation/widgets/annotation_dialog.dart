import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doc_viewer_app/features/annotations/domain/entities/annotation.dart';

/// Dialog for adding or editing annotations
class AnnotationDialog extends StatefulWidget {
  final Annotation? existingAnnotation;
  final String? selectedText;
  final int? lineNumber;
  final String currentTheme;

  const AnnotationDialog({
    super.key,
    this.existingAnnotation,
    this.selectedText,
    this.lineNumber,
    required this.currentTheme,
  });

  @override
  State<AnnotationDialog> createState() => _AnnotationDialogState();
}

class _AnnotationDialogState extends State<AnnotationDialog> {
  late TextEditingController _contentController;
  late TextEditingController _anchorController;
  late FocusNode _anchorFocusNode;
  String _selectedColor = 'yellow';
  final _tagController = TextEditingController();
  final _tags = <String>[];
  bool _anchorAutoSelected = false;

  @override
  void initState() {
    super.initState();

    _contentController = TextEditingController(
      text: widget.existingAnnotation?.content ?? '',
    );

    _anchorController = TextEditingController(
      text: widget.existingAnnotation?.anchorText ??
          widget.selectedText ??
          '',
    );

    _anchorFocusNode = FocusNode();
    _anchorFocusNode.addListener(_onAnchorFocusChange);

    _selectedColor = widget.existingAnnotation?.color ?? 'yellow';
    _tags.addAll(widget.existingAnnotation?.tags ?? []);
  }

  void _onAnchorFocusChange() {
    // Select all text when field receives focus for the first time
    // (only if there's pre-filled text from selection)
    if (_anchorFocusNode.hasFocus &&
        !_anchorAutoSelected &&
        _anchorController.text.isNotEmpty &&
        widget.selectedText != null) {
      _anchorController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _anchorController.text.length,
      );
      _anchorAutoSelected = true;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _anchorController.dispose();
    _tagController.dispose();
    _anchorFocusNode.removeListener(_onAnchorFocusChange);
    _anchorFocusNode.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                widget.existingAnnotation == null
                    ? 'Add Annotation'
                    : 'Edit Annotation',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 24),

              // Anchor text
              Text(
                'Anchor Text:',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _anchorController,
                focusNode: _anchorFocusNode,
                autofocus: widget.selectedText == null,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Text to anchor this note to...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Note content
              Text(
                'Note:',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _contentController,
                autofocus: widget.selectedText != null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Enter your note here...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Color picker
              Text(
                'Color:',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  'yellow',
                  'red',
                  'blue',
                  'green',
                  'orange',
                  'purple',
                ].map((color) {
                  return _ColorOption(
                    color: color,
                    isSelected: _selectedColor == color,
                    onSelected: () {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Tags
              Text(
                'Tags:',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        hintText: 'Add tag...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(CupertinoIcons.add),
                    onPressed: _addTag,
                  ),
                ],
              ),

              if (_tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _tags.map((tag) {
                    return Chip(
                      label: Text('#$tag'),
                      onDeleted: () => _removeTag(tag),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_anchorController.text.isEmpty ||
                          _contentController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all required fields'),
                          ),
                        );
                        return;
                      }

                      final result = AnnotationDialogResult(
                        anchorText: _anchorController.text,
                        content: _contentController.text,
                        color: _selectedColor,
                        tags: _tags,
                      );
                      Navigator.pop(context, result);
                    },
                    child: Text(widget.existingAnnotation == null
                        ? 'Add'
                        : 'Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final String color;
  final bool isSelected;
  final VoidCallback onSelected;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.onSelected,
  });

  Color get _displayColor {
    switch (color) {
      case 'yellow':
        return const Color(0xFFFFD700);
      case 'red':
        return const Color(0xFFFF6B6B);
      case 'blue':
        return const Color(0xFF4ECDC4);
      case 'green':
        return const Color(0xFF95E1D3);
      case 'orange':
        return const Color(0xFFFFAA5A);
      case 'purple':
        return const Color(0xFFB695F8);
      default:
        return const Color(0xFFFFD700);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _displayColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}

/// Result from the annotation dialog
class AnnotationDialogResult {
  final String anchorText;
  final String content;
  final String color;
  final List<String> tags;

  AnnotationDialogResult({
    required this.anchorText,
    required this.content,
    required this.color,
    required this.tags,
  });
}
