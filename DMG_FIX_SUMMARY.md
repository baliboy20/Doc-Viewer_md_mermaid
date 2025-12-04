# DMG Packaging Script Fix

## Issue
The `package_dmg.sh` script failed with the error:
```
Error: App bundle not found at build/macos/Build/Products/Release/doc_viewer_app.app
```

And later had mount point detection issues:
```
cp: /Volumes/Florence 1.2.0 Installer/.VolumeIcon.icns: No such file or directory
```

## Root Causes

### 1. Incorrect App Bundle Name
The script was looking for `doc_viewer_app.app` but the actual built app is `Florence.app`

### 2. Mount Point Detection Issue
The regex to extract the mount point from `hdiutil attach` output wasn't working correctly, causing the icon copy to fail.

## Fixes Applied

### Fix 1: Updated App Bundle Name
**File**: `package_dmg.sh` (Line 10)
```bash
APP_BUNDLE_NAME="Florence"  # was: doc_viewer (or doc_viewer_app)
```

### Fix 2: Improved Mount Point Detection
**File**: `package_dmg.sh` (Line 82)

**Before**:
```bash
MOUNT_DIR=$(hdiutil attach "$TMP_DMG" | grep -E '^/dev/' | sed 's/.*\(\/Volumes\/.*\)/\1/')
```

**After**:
```bash
MOUNT_DIR=$(hdiutil attach "$TMP_DMG" | grep -E 'Volumes' | sed 's|^.*/Volumes/|/Volumes/|' | tail -1)
```

**Why this works better**:
- Uses `grep -E 'Volumes'` to find the line with volume path
- Uses `sed` with `|` delimiter to avoid escaping issues
- Uses `tail -1` to get the last match (the actual mount point)

## Verification

Successfully created DMG:
```
build/Florence_1.2.0_Barbados.dmg
Size: 20M
```

### DMG Contents:
- ✅ Florence.app (with custom icon)
- ✅ Applications symlink
- ✅ Custom volume icon
- ✅ Configured window layout
- ✅ Proper positioning of icons

## Testing the DMG

1. **Mount the DMG**:
   ```bash
   open build/Florence_1.2.0_Barbados.dmg
   ```

2. **Verify**:
   - Window should open with Florence app and Applications folder
   - Icons should be positioned nicely
   - Volume should have custom icon
   - User can drag Florence to Applications

3. **Install**:
   - Drag Florence.app to Applications folder
   - Launch from Applications

## Script Usage

```bash
# Make sure app is built
flutter build macos --release

# Package as DMG
./package_dmg.sh
```

## Output Location
```
build/Florence_1.2.0_Barbados.dmg
```

## Related Files

1. `package_dmg.sh` - Main packaging script
2. `pubspec.yaml` - Contains version info (1.2.0)
3. `build/macos/Build/Products/Release/Florence.app` - Source app bundle
4. `macos/Runner/Assets.xcassets/AppIcon.appiconset/` - App icon sources

## Success Indicators

When running the script, you should see:
```
=====================================
  DMG Packaging Script
=====================================

App: Florence
Version: 1.2.0
Version Name: Barbados

✓ Creating DMG directory...
✓ Copying app bundle...
✓ Creating Applications symlink...
✓ Creating temporary DMG...
✓ Mounting temporary DMG...
✓ Applying custom icon to DMG...
✓ Configuring DMG appearance...
✓ Unmounting temporary DMG...
✓ Compressing final DMG...
✓ Cleaning up...

=====================================
  DMG created successfully!
=====================================

Output: build/Florence_1.2.0_Barbados.dmg
Size: 20M
```

## Troubleshooting

### If "App bundle not found" error occurs:
1. Make sure you've run: `flutter build macos --release`
2. Check that `build/macos/Build/Products/Release/Florence.app` exists

### If mount errors occur:
1. Detach any existing volumes: `hdiutil detach "/Volumes/Florence 1.2.0 Installer"`
2. Remove old DMG files: `rm build/*.dmg build/tmp_*.dmg`
3. Run the script again

### If icon not applied:
1. Verify icon exists: `ls build/macos/Build/Products/Release/Florence.app/Contents/Resources/AppIcon.icns`
2. Rebuild app if missing: `flutter build macos --release`
