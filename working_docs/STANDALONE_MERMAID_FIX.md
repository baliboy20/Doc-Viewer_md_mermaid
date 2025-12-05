# Standalone .mermaid File Interactive Fix

## Issue
Interactive controls (dropdowns, clickable elements) in standalone `.mermaid` files were not working, even though they worked in embedded Mermaid diagrams within markdown files.

## Root Cause
1. The `MermaidFileViewer` had a fixed height of 600px which may have constrained interactions
2. The WebView lacked explicit gesture recognizers needed for macOS
3. ClipBehavior may have been blocking some pointer events

## Changes Made

### 1. **MermaidRenderer - Gesture Recognizers** (`lib/presentation/widgets/mermaid_renderer.dart:432-444`)
Added explicit gesture recognizers to the WebViewWidget:
- `TapGestureRecognizer` - For clicks/taps
- `LongPressGestureRecognizer` - For long press interactions
- `VerticalDragGestureRecognizer` - For scroll and drag operations

This ensures all pointer events are properly forwarded to the WebView content on macOS.

### 2. **MermaidFileViewer - Dynamic Height** (`lib/presentation/widgets/mermaid_file_viewer.dart:137-141`)
- Removed fixed `height: 600` parameter
- Now uses dynamic height from MermaidRenderer
- Updated clipBehavior settings for better rendering

### 3. **Added Foundation Import** (`lib/presentation/widgets/mermaid_renderer.dart:2`)
- Required for `Factory<T>` type used in gesture recognizers

## Testing

### Test File Created
A test file `test_interactive.mermaid` has been created with:
- Clickable nodes
- Decision branches
- Interactive callbacks
- Custom styling

### How to Test
1. Rebuild the app:
   ```bash
   flutter build macos --release
   ```

2. Open the test file in the app:
   - Navigate to `test_interactive.mermaid` in your file browser
   - Open it in Florence

3. Try interacting with:
   - Click on the "Start Process" node
   - Click on decision branches
   - Click on process boxes
   - Use the zoom controls
   - Try the resize handle at the bottom

### What Should Work Now
✅ Clicking on nodes with `click` callbacks
✅ Dropdown menus (if your diagram has them)
✅ Interactive state transitions
✅ Hover effects
✅ Zoom in/out controls
✅ Drag to resize the diagram height
✅ All pointer-based interactions

## Technical Details

### Gesture Recognizers Explained
Flutter's WebView on macOS requires explicit gesture recognizer factories to pass events:

```dart
gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
  Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
  Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
  Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
}
```

Without these, the WebView receives the events but doesn't properly recognize them as gestures, causing interactive elements to not respond.

### Why Both Embedded and Standalone Now Work
Both `MermaidDiagram` (for embedded) and `MermaidFileViewer` (for standalone) use the same `MermaidRenderer` component. All fixes applied to `MermaidRenderer` benefit both:

1. ✅ NavigationDelegate - allows navigation
2. ✅ Gesture recognizers - forwards events properly
3. ✅ Security level 'loose' - enables interactive features
4. ✅ Pointer events CSS - ensures elements are clickable
5. ✅ JavaScript event enabling - activates all interactive elements post-render

## Debugging

If interactions still don't work:

1. **Check logs** for:
   ```
   [MermaidRenderer] Mermaid WebView: Interactive elements found: X
   ```
   The number should be > 0 if there are clickable elements

2. **Verify Mermaid syntax** - some diagrams need specific syntax for interactivity:
   ```mermaid
   graph TD
       A[Node] -->|label| B[Another Node]
       click A callback "Tooltip text"
   ```

3. **Test zoom controls** - if zoom works but diagram clicks don't, it's a Mermaid config issue

4. **Try different diagram types**:
   - Flowcharts with `click` directives
   - State diagrams with transitions
   - Sequence diagrams with notes

## Known Limitations

- Links to external URLs (`click A "https://..."`) may be blocked by security settings
- Very complex interactive diagrams may have performance issues
- Some advanced Mermaid features may not work in WebView context

## Files Modified

1. `lib/presentation/widgets/mermaid_renderer.dart` - Core rendering component
2. `lib/presentation/widgets/mermaid_file_viewer.dart` - Standalone file viewer
3. `MERMAID_INTERACTIVE_FIX.md` - General Mermaid fix documentation

## Rebuild Required

```bash
flutter build macos --release
./package_dmg.sh  # If you want to create a DMG
```
