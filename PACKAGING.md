# DMG Packaging Guide

This guide explains how to package the doc_viewer_app as a distributable DMG file for macOS.

## Prerequisites

- Xcode Command Line Tools installed
- Flutter SDK configured
- macOS development environment

## Quick Start

1. **Build the release version:**
   ```bash
   flutter build macos --release
   ```

2. **Package as DMG:**
   ```bash
   ./package_dmg.sh
   ```

3. **Find your DMG:**
   The DMG file will be created at: `build/doc_viewer_app.dmg`

## What the Script Does

The `package_dmg.sh` script automates the following:

1. Validates that the release build exists
2. Creates a temporary directory structure
3. Copies the app bundle
4. Creates a symbolic link to the Applications folder
5. Applies the custom AppIcon from your app to the DMG
6. Configures the DMG appearance (window size, icon positions)
7. Compresses the DMG to reduce file size
8. Cleans up temporary files

## Custom Icon Configuration

The script automatically uses the `AppIcon.icns` from your built app. The icon has been configured in:
- **Icon Asset**: `macos/Runner/Assets.xcassets/AppIcon.appiconset/`
- **Info.plist**: Set to use "AppIcon" (macos/Runner/Info.plist:10)

Your app icon includes multiple sizes:
- 16x16, 32x32, 64x64, 128x128, 256x256, 512x512, 1024x1024

## DMG Layout

The DMG will contain:
- Your app bundle (doc_viewer_app.app)
- A link to the Applications folder

Users can simply drag the app to Applications to install.

## Customization

You can modify the script to customize:

- **Volume name**: Change `VOLUME_NAME` variable
- **DMG name**: Change `DMG_NAME` variable
- **Window size**: Modify the `bounds` in the AppleScript section
- **Icon positions**: Adjust the `position` values in the AppleScript

## Troubleshooting

**Error: App bundle not found**
- Make sure to run `flutter build macos --release` first

**DMG created but icon doesn't show**
- Verify the icon exists: `ls -la build/macos/Build/Products/Release/doc_viewer_app.app/Contents/Resources/AppIcon.icns`
- Rebuild the app to regenerate the icon

**SetFile command not found**
- Install Xcode Command Line Tools: `xcode-select --install`

## Distribution

Once created, you can distribute the DMG by:
1. Uploading to your website
2. Sharing via cloud storage
3. Submitting to app stores

For App Store distribution, additional code signing and notarization steps are required.
