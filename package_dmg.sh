#!/bin/bash

# Script to package doc_viewer_app as a DMG file with custom icon
# Usage: ./package_dmg.sh

set -e  # Exit on error

# Configuration
APP_NAME="Florence"
APP_BUNDLE_NAME="Florence"
BUILD_DIR="build/macos/Build/Products/Release"
APP_BUNDLE="$BUILD_DIR/$APP_BUNDLE_NAME.app"
DMG_DIR="build/dmg"

# Extract version from pubspec.yaml
VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: *//' | sed 's/+.*//')
VERSION_NAME="Barbados"

DMG_NAME="${APP_NAME}_${VERSION}_${VERSION_NAME}.dmg"
VOLUME_NAME="$APP_NAME $VERSION Installer"
ICON_FILE="$BUILD_DIR/$APP_BUNDLE_NAME.app/Contents/Resources/AppIcon.icns"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  DMG Packaging Script${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo -e "App: ${YELLOW}$APP_NAME${NC}"
echo -e "Version: ${YELLOW}$VERSION${NC}"
echo -e "Version Name: ${YELLOW}$VERSION_NAME${NC}"
echo ""

# Check if the app bundle exists
if [ ! -d "$APP_BUNDLE" ]; then
    echo -e "${RED}Error: App bundle not found at $APP_BUNDLE${NC}"
    echo -e "${YELLOW}Please build the release version first:${NC}"
    echo "  flutter build macos --release"
    exit 1
fi

# Check if icon file exists
if [ ! -f "$ICON_FILE" ]; then
    echo -e "${YELLOW}Warning: Icon file not found at $ICON_FILE${NC}"
    echo "DMG will be created without custom icon"
    ICON_FILE=""
fi

# Create DMG directory
echo -e "${GREEN}Creating DMG directory...${NC}"
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"

# Copy the app bundle to DMG directory
echo -e "${GREEN}Copying app bundle...${NC}"
cp -R "$APP_BUNDLE" "$DMG_DIR/"

# Create a symbolic link to Applications folder
echo -e "${GREEN}Creating Applications symlink...${NC}"
ln -s /Applications "$DMG_DIR/Applications"

# Remove existing DMG if it exists
if [ -f "build/$DMG_NAME" ]; then
    echo -e "${GREEN}Removing existing DMG...${NC}"
    rm "build/$DMG_NAME"
fi

# Create temporary DMG
echo -e "${GREEN}Creating temporary DMG...${NC}"
TMP_DMG="build/tmp_$DMG_NAME"
hdiutil create -volname "$VOLUME_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDRW \
    "$TMP_DMG"

# Mount the temporary DMG
echo -e "${GREEN}Mounting temporary DMG...${NC}"
MOUNT_DIR=$(hdiutil attach "$TMP_DMG" | grep -E 'Volumes' | sed 's|^.*/Volumes/|/Volumes/|' | tail -1)

# Apply custom icon to the DMG volume if icon exists
if [ -n "$ICON_FILE" ] && [ -f "$ICON_FILE" ]; then
    echo -e "${GREEN}Applying custom icon to DMG...${NC}"

    # Copy icon file to volume
    cp "$ICON_FILE" "$MOUNT_DIR/.VolumeIcon.icns"

    # Set custom icon attribute
    SetFile -c icnC "$MOUNT_DIR/.VolumeIcon.icns"
    SetFile -a C "$MOUNT_DIR"
fi

# Set background and icon positions (optional but recommended)
echo -e "${GREEN}Configuring DMG appearance...${NC}"
osascript <<EOD
tell application "Finder"
    tell disk "$VOLUME_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {100, 100, 600, 450}
        set theViewOptions to the icon view options of container window
        set arrangement of theViewOptions to not arranged
        set icon size of theViewOptions to 128
        set position of item "$APP_BUNDLE_NAME.app" of container window to {125, 175}
        set position of item "Applications" of container window to {375, 175}
        update without registering applications
        delay 2
        close
    end tell
end tell
EOD

# Unmount the temporary DMG
echo -e "${GREEN}Unmounting temporary DMG...${NC}"
hdiutil detach "$MOUNT_DIR"

# Convert to compressed DMG
echo -e "${GREEN}Compressing final DMG...${NC}"
hdiutil convert "$TMP_DMG" \
    -format UDZO \
    -imagekey zlib-level=9 \
    -o "build/$DMG_NAME"

# Clean up
echo -e "${GREEN}Cleaning up...${NC}"
rm -rf "$DMG_DIR"
rm "$TMP_DMG"

echo ""
echo -e "${GREEN}=====================================${NC}"
echo -e "${GREEN}  DMG created successfully!${NC}"
echo -e "${GREEN}=====================================${NC}"
echo ""
echo -e "Output: ${YELLOW}build/$DMG_NAME${NC}"
echo ""

# Get file size
FILE_SIZE=$(du -h "build/$DMG_NAME" | cut -f1)
echo -e "Size: ${YELLOW}$FILE_SIZE${NC}"
echo ""
