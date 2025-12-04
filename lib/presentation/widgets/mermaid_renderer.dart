import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/seez_theme.dart';
import '../theme/app_theme.dart';
import '../../infrastructure/services/app_logger.dart';

/// Renders Mermaid diagrams using WebView and mermaid.js
class MermaidRenderer extends StatefulWidget {
  final String diagramCode;
  final String currentTheme;
  final double? height;

  const MermaidRenderer({
    super.key,
    required this.diagramCode,
    required this.currentTheme,
    this.height,
  });

  @override
  State<MermaidRenderer> createState() => _MermaidRendererState();
}

class _MermaidRendererState extends State<MermaidRenderer> {
  late final WebViewController _controller;
  double _webViewHeight = 400.0;
  bool _isLoading = true;
  double _zoomLevel = 1.0;
  static const double _minHeight = 200.0;
  static const double _maxHeight = 1200.0;

  @override
  void initState() {
    super.initState();
    _initializeController();

    // Hide loading indicator after 1 second to show the WebView
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  void _initializeController() {
    // Get theme colors
    final backgroundColor = _getBackgroundColor();
    final textColor = _getTextColor();
    final primaryColor = _getPrimaryColor();

    // Escape the diagram code for JavaScript
    final escapedCode = _escapeForJavaScript(widget.diagramCode);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation within the WebView for interactive diagrams
            return NavigationDecision.navigate;
          },
        ),
      );

    // Only set background color on non-macOS platforms to avoid opacity error
    if (!Platform.isMacOS) {
      _controller.setBackgroundColor(_getFlutterBackgroundColor());
    }

    _controller
      ..addJavaScriptChannel(
        'ResizeChannel',
        onMessageReceived: (JavaScriptMessage message) {
          final height = double.tryParse(message.message);
          if (height != null && mounted) {
            setState(() {
              _webViewHeight = height + 40; // Add padding
              _isLoading = false;
            });
          }
        },
      )
      ..addJavaScriptChannel(
        'ConsoleLog',
        onMessageReceived: (JavaScriptMessage message) {
          AppLogger.debug('Mermaid WebView: ${message.message}', tag: 'MermaidRenderer');
        },
      )
      ..loadHtmlString(_buildHtmlContent(
        escapedCode,
        backgroundColor,
        textColor,
        primaryColor,
      ));
  }

  Color _getFlutterBackgroundColor() {
    if (widget.currentTheme == 'seez') {
      return SeezTheme.parchmentBackground;
    } else if (widget.currentTheme == 'dark') {
      return AppTheme.darkerBackground;
    }
    return AppTheme.lightBackground;
  }

  String _escapeForJavaScript(String code) {
    return code
        .replaceAll('\\', '\\\\')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll("'", "\\'")
        .replaceAll('"', '\\"');
  }

  String _getBackgroundColor() {
    if (widget.currentTheme == 'seez') {
      return '#${SeezTheme.parchmentBackground.toARGB32().toRadixString(16).substring(2)}';
    } else if (widget.currentTheme == 'dark') {
      return '#${AppTheme.darkerBackground.toARGB32().toRadixString(16).substring(2)}';
    }
    return '#${AppTheme.lightBackground.toARGB32().toRadixString(16).substring(2)}';
  }

  String _getTextColor() {
    if (widget.currentTheme == 'seez') {
      return '#${SeezTheme.darkBrownText.toARGB32().toRadixString(16).substring(2)}';
    } else if (widget.currentTheme == 'dark') {
      return '#${AppTheme.textOnDark.toARGB32().toRadixString(16).substring(2)}';
    }
    return '#${AppTheme.textPrimary.toARGB32().toRadixString(16).substring(2)}';
  }

  String _getPrimaryColor() {
    if (widget.currentTheme == 'seez') {
      return '#${SeezTheme.primaryBrown.toARGB32().toRadixString(16).substring(2)}';
    }
    return '#${AppTheme.primaryBlue.toARGB32().toRadixString(16).substring(2)}';
  }

  String _buildHtmlContent(
    String diagramCode,
    String bgColor,
    String textColor,
    String primaryColor,
  ) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://cdn.jsdelivr.net/npm/mermaid@10.6.1/dist/mermaid.min.js"></script>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body {
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      background-color: $bgColor;
      padding: 20px;
      overflow-x: auto;
      -webkit-user-select: none;
      user-select: none;
    }
    #diagram {
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 200px;
      transform-origin: center top;
      transition: transform 0.3s ease;
      pointer-events: auto;
    }
    #diagram svg {
      max-width: 100%;
      height: auto;
    }
    /* Enable pointer events for interactive elements */
    #diagram * {
      pointer-events: auto;
    }
    /* Ensure buttons and interactive elements are clickable */
    button, select, input, a {
      pointer-events: auto !important;
      cursor: pointer;
    }
    .error {
      color: #CF222E;
      padding: 16px;
      background-color: #FFE8E8;
      border-radius: 8px;
      border-left: 4px solid #CF222E;
      font-size: 14px;
    }
  </style>
</head>
<body>
  <div id="diagram"></div>
  <script>
    // Configure Mermaid
    mermaid.initialize({
      startOnLoad: false,
      theme: '${widget.currentTheme == 'dark' ? 'dark' : 'default'}',
      securityLevel: 'loose',
      themeVariables: {
        primaryColor: '$primaryColor',
        primaryTextColor: '$textColor',
        primaryBorderColor: '$primaryColor',
        lineColor: '$textColor',
        secondaryColor: '${widget.currentTheme == 'seez' ? '#F5E6D3' : '#e8f4f8'}',
        tertiaryColor: '${widget.currentTheme == 'seez' ? '#FFF8F0' : '#ffffff'}',
        background: '$bgColor',
        mainBkg: '${widget.currentTheme == 'seez' ? '#F5E6D3' : '#ffffff'}',
        textColor: '$textColor',
        fontSize: '14px',
        fontFamily: 'Inter, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif'
      },
      flowchart: {
        useMaxWidth: true,
        htmlLabels: true,
        curve: 'basis'
      },
      sequence: {
        useMaxWidth: true
      },
      gantt: {
        useMaxWidth: true
      }
    });

    // Render diagram
    const diagramCode = \`$diagramCode\`;

    async function renderDiagram() {
      try {
        const { svg } = await mermaid.render('mermaidDiagram', diagramCode);
        const diagramContainer = document.getElementById('diagram');
        diagramContainer.innerHTML = svg;

        // Enable all interactive elements after rendering
        const svgElement = diagramContainer.querySelector('svg');
        if (svgElement) {
          // Ensure SVG and all children can receive events
          svgElement.style.pointerEvents = 'auto';

          // Find and enable all interactive elements
          const interactiveElements = svgElement.querySelectorAll('a, button, [onclick], [class*="clickable"]');
          interactiveElements.forEach(el => {
            el.style.pointerEvents = 'auto';
            el.style.cursor = 'pointer';
          });

          // Log for debugging
          if (window.ConsoleLog) {
            window.ConsoleLog.postMessage('Interactive elements found: ' + interactiveElements.length);
          }
        }

        // Notify Flutter about the height - try multiple times to ensure it gets through
        notifyHeight();
      } catch (error) {
        if (window.ConsoleLog) {
          window.ConsoleLog.postMessage('Mermaid rendering error: ' + error.message);
        }
        console.error('Mermaid rendering error:', error);
        document.getElementById('diagram').innerHTML =
          '<div class="error"><strong>Diagram Rendering Error:</strong><br>' +
          error.message + '</div>';

        // Still notify about height
        notifyHeight();
      }
    }

    function notifyHeight() {
      // Try immediately
      sendHeight();

      // Try again after delays to ensure message gets through
      setTimeout(sendHeight, 50);
      setTimeout(sendHeight, 200);
      setTimeout(sendHeight, 500);
    }

    function sendHeight() {
      try {
        const height = document.getElementById('diagram').offsetHeight;
        if (window.ResizeChannel && height > 0) {
          window.ResizeChannel.postMessage(height.toString());
        }
      } catch (e) {
        console.error('Error sending height:', e);
      }
    }

    renderDiagram();
  </script>
</body>
</html>
''';
  }

  void _zoomIn() {
    if (_zoomLevel < 2.0) {
      setState(() {
        _zoomLevel += 0.25;
      });
      _controller.runJavaScript('document.getElementById("diagram").style.transform = "scale($_zoomLevel)";');
    }
  }

  void _zoomOut() {
    if (_zoomLevel > 0.5) {
      setState(() {
        _zoomLevel -= 0.25;
      });
      _controller.runJavaScript('document.getElementById("diagram").style.transform = "scale($_zoomLevel)";');
    }
  }

  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
    });
    _controller.runJavaScript('document.getElementById("diagram").style.transform = "scale(1)";');
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.currentTheme == 'seez'
        ? SeezTheme.mediumBrownBorder
        : (widget.currentTheme == 'dark'
            ? AppTheme.borderDark
            : AppTheme.border);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Zoom controls
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.currentTheme == 'seez'
                ? SeezTheme.lightBeigeGradient1
                : (widget.currentTheme == 'dark'
                    ? AppTheme.darkBackground
                    : AppTheme.lighterBackground),
            border: Border(
              bottom: BorderSide(
                color: borderColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.zoom_in,
                size: 16,
                color: widget.currentTheme == 'seez'
                    ? SeezTheme.darkBrownText
                    : (widget.currentTheme == 'dark'
                        ? AppTheme.textOnDark
                        : AppTheme.textPrimary),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(CupertinoIcons.minus_circle),
                iconSize: 20,
                onPressed: _zoomOut,
                tooltip: 'Zoom Out',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.currentTheme == 'seez'
                      ? SeezTheme.lightCreamTile
                      : (widget.currentTheme == 'dark'
                          ? AppTheme.borderDark
                          : AppTheme.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${(_zoomLevel * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.currentTheme == 'seez'
                        ? SeezTheme.darkBrownText
                        : (widget.currentTheme == 'dark'
                            ? AppTheme.textOnDark
                            : AppTheme.textPrimary),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(CupertinoIcons.plus_circle),
                iconSize: 20,
                onPressed: _zoomIn,
                tooltip: 'Zoom In',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(CupertinoIcons.arrow_counterclockwise),
                iconSize: 20,
                onPressed: _resetZoom,
                tooltip: 'Reset Zoom',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        // Diagram area - with resizable height
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: widget.height ?? _webViewHeight,
          child: Stack(
            children: [
              WebViewWidget(
                controller: _controller,
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<VerticalDragGestureRecognizer>(
                    () => VerticalDragGestureRecognizer(),
                  ),
                  Factory<TapGestureRecognizer>(
                    () => TapGestureRecognizer(),
                  ),
                  Factory<LongPressGestureRecognizer>(
                    () => LongPressGestureRecognizer(),
                  ),
                },
              ),
              if (_isLoading)
                Center(
                  child: CircularProgressIndicator(
                    color: widget.currentTheme == 'seez'
                        ? SeezTheme.primaryBrown
                        : AppTheme.primaryBlue,
                  ),
                ),
            ],
          ),
        ),
        // Resize Handle
        GestureDetector(
          onVerticalDragUpdate: (details) {
            setState(() {
              _webViewHeight = (_webViewHeight + details.delta.dy)
                  .clamp(_minHeight, _maxHeight);
            });
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.resizeRow,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: widget.currentTheme == 'seez'
                    ? SeezTheme.lightBeigeGradient1
                    : (widget.currentTheme == 'dark'
                        ? AppTheme.darkBackground
                        : AppTheme.lighterBackground),
                border: Border(
                  top: BorderSide(
                    color: borderColor,
                    width: 1,
                  ),
                ),
              ),
              child: Center(
                child: Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
