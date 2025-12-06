import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/annotation.dart';

/// Annotation gutter that shows badges as a vertical list at the top
class PositionedAnnotationGutter extends StatelessWidget {
  final List<Annotation> annotations;
  final String currentTheme;
  final Function(Annotation) onAnnotationTap;
  final int totalLines;
  final double lineHeight;
  final double topPadding;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const PositionedAnnotationGutter({
    super.key,
    required this.annotations,
    required this.currentTheme,
    required this.onAnnotationTap,
    required this.totalLines,
    required this.isCollapsed,
    required this.onToggleCollapse,
    this.lineHeight = 24.0, // Not used in list mode
    this.topPadding = 24.0,
  });

  Color _getAnnotationColor(String color) {
    switch (color.toLowerCase()) {
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: isCollapsed ? 24 : 30,
      decoration: BoxDecoration(
        color: isCollapsed
            ? Colors.transparent
            : (currentTheme == 'seez'
                ? const Color(0xFFF5F0E8)
                : (currentTheme == 'dark'
                    ? const Color(0xFF1E1E1E)
                    : const Color(0xFFF8F8F8))),
        border: isCollapsed
            ? null
            : Border(
                right: BorderSide(
                  color: currentTheme == 'seez'
                      ? const Color(0xFFD4C5A9)
                      : (currentTheme == 'dark'
                          ? const Color(0xFF3E3E3E)
                          : const Color(0xFFE0E0E0)),
                  width: 1,
                ),
              ),
      ),
      child: Column(
        children: [
          // Collapse/expand button at the top
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: IconButton(
              icon: Icon(
                isCollapsed
                    ? CupertinoIcons.chevron_right
                    : CupertinoIcons.chevron_left,
                size: 12,
                color: currentTheme == 'seez'
                    ? const Color(0xFF8B7355)
                    : (currentTheme == 'dark'
                        ? const Color(0xFFB0B0B0)
                        : const Color(0xFF757575)),
              ),
              iconSize: 12,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onToggleCollapse,
              tooltip: isCollapsed ? 'Show annotations' : 'Hide annotations',
            ),
          ),

          // Annotation badges list
          if (!isCollapsed && annotations.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
                itemCount: annotations.length,
                itemBuilder: (context, index) {
                  final annotation = annotations[index];
                  final color = _getAnnotationColor(annotation.color);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: _SpeechBubbleTooltip(
                      message: annotation.anchorText,
                      color: color,
                      child: GestureDetector(
                        onTap: () => onAnnotationTap(annotation),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                CupertinoIcons.bookmark,
                                size: 14,
                                color: color,
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '${index + 1}',
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom speech bubble tooltip with stem pointing to badge
class _SpeechBubbleTooltip extends StatefulWidget {
  final Widget child;
  final String message;
  final Color color;

  const _SpeechBubbleTooltip({
    required this.child,
    required this.message,
    required this.color,
  });

  @override
  State<_SpeechBubbleTooltip> createState() => _SpeechBubbleTooltipState();
}

class _SpeechBubbleTooltipState extends State<_SpeechBubbleTooltip> {
  bool _isHovered = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    _removeTooltip();
    super.dispose();
  }

  void _showTooltip() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 200,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(40, -30), // Position to the right
          child: Material(
            color: Colors.transparent,
            child: CustomPaint(
              painter: _SpeechBubblePainter(color: widget.color),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Text(
                  widget.message,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_isHovered && mounted) {
              _showTooltip();
            }
          });
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          _removeTooltip();
        },
        child: widget.child,
      ),
    );
  }
}

/// Custom painter for speech bubble with stem
class _SpeechBubblePainter extends CustomPainter {
  final Color color;

  _SpeechBubblePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();

    // Start from left with stem
    const stemWidth = 8.0;
    const stemHeight = 10.0;
    const radius = 8.0;

    // Draw stem (triangle pointing left)
    path.moveTo(0, size.height / 2 - stemHeight / 2);
    path.lineTo(-stemWidth, size.height / 2);
    path.lineTo(0, size.height / 2 + stemHeight / 2);

    // Draw rounded rectangle bubble
    path.lineTo(0, radius);
    path.arcToPoint(
      Offset(radius, 0),
      radius: const Radius.circular(radius),
    );
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(
      Offset(size.width, radius),
      radius: const Radius.circular(radius),
    );
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(
      Offset(size.width - radius, size.height),
      radius: const Radius.circular(radius),
    );
    path.lineTo(radius, size.height);
    path.arcToPoint(
      Offset(0, size.height - radius),
      radius: const Radius.circular(radius),
    );
    path.close();

    // Draw shadow
    canvas.drawPath(path, shadowPaint);

    // Draw bubble
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SpeechBubblePainter oldDelegate) =>
      oldDelegate.color != color;
}
