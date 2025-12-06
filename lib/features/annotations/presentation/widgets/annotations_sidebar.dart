import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:doc_viewer_app/features/annotations/domain/entities/annotation.dart';

/// Sidebar showing list of all annotations for current file
class AnnotationsSidebar extends StatelessWidget {
  final List<Annotation> annotations;
  final Function(Annotation) onAnnotationTap;
  final Function(Annotation) onEditAnnotation;
  final Function(String) onDeleteAnnotation;
  final String currentTheme;

  const AnnotationsSidebar({
    super.key,
    required this.annotations,
    required this.onAnnotationTap,
    required this.onEditAnnotation,
    required this.onDeleteAnnotation,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    if (annotations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No annotations yet',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: annotations.length,
      itemBuilder: (context, index) {
        final annotation = annotations[index];
        return _AnnotationCard(
          annotation: annotation,
          onTap: () => onAnnotationTap(annotation),
          onEdit: () => onEditAnnotation(annotation),
          onDelete: () => onDeleteAnnotation(annotation.id),
          currentTheme: currentTheme,
        );
      },
    );
  }
}

class _AnnotationCard extends StatelessWidget {
  final Annotation annotation;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final String currentTheme;

  const _AnnotationCard({
    required this.annotation,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.currentTheme,
  });

  Color get _cardColor {
    switch (annotation.color.toLowerCase()) {
      case 'yellow':
        return const Color(0xFFFFD700).withOpacity(0.2);
      case 'red':
        return const Color(0xFFFF6B6B).withOpacity(0.2);
      case 'blue':
        return const Color(0xFF4ECDC4).withOpacity(0.2);
      case 'green':
        return const Color(0xFF95E1D3).withOpacity(0.2);
      case 'orange':
        return const Color(0xFFFFAA5A).withOpacity(0.2);
      case 'purple':
        return const Color(0xFFB695F8).withOpacity(0.2);
      default:
        return const Color(0xFFFFD700).withOpacity(0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: _cardColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Anchor text
              Text(
                annotation.anchorText,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Content
              Text(
                annotation.content,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black87,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // Tags
              if (annotation.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: annotation.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '#$tag',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 8),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(annotation.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.black45,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.pencil, size: 16),
                        onPressed: onEdit,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(CupertinoIcons.trash, size: 16),
                        onPressed: () {
                          // Show confirmation dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Annotation'),
                              content: const Text(
                                  'Are you sure you want to delete this annotation?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onDelete();
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                        },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
