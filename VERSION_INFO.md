# Version Information

## Current Release
- **Version Number**: 1.2.0
- **Version Name**: Barbados
- **Build Number**: 1

## Version Configuration

### pubspec.yaml
The version is defined in `pubspec.yaml`:
```yaml
version: 1.2.0+1
```

Where:
- `1.2.0` = Version number (major.minor.patch)
- `+1` = Build number

### Version Name
The version name "Barbados" is configured in:
- **Splash Screen**: `lib/presentation/screens/splash_screen.dart:41`
- **DMG Script**: `package_dmg.sh:17`
- **macOS Config**: `macos/Runner/Configs/AppInfo.xcconfig:17`

## Display Locations

### 1. Splash Screen
The version is displayed at the bottom of the splash screen:
- Format: `v1.2.0 "Barbados"`
- Uses `package_info_plus` to read from pubspec.yaml
- Updates automatically on rebuild

### 2. DMG Filename
When you package the app, the DMG will be named:
- Format: `Florence_1.2.0_Barbados.dmg`
- Located in: `build/`

### 3. DMG Volume Name
The mounted DMG volume shows:
- Format: `Florence 1.2.0 Installer`

## Updating Version

To update the version for a new release:

1. **Update version number in pubspec.yaml:**
   ```yaml
   version: 1.3.0+1  # Change to new version
   ```

2. **Update version name in three places:**
   - `lib/presentation/screens/splash_screen.dart:41`
   - `package_dmg.sh:17`
   - `macos/Runner/Configs/AppInfo.xcconfig:17`

3. **Rebuild the app:**
   ```bash
   flutter build macos --release
   ```

4. **Package as DMG:**
   ```bash
   ./package_dmg.sh
   ```

## Version History

### 1.2.0 "Barbados" (Current)
- Custom Florence icon implementation
- DMG packaging with version info
- Version display on splash screen

### 1.0.0 (Initial Release)
- Basic documentation viewer functionality
