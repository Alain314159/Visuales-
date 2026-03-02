# 📋 Release Checklist - Visuales UCLV

## Pre-Release Checklist

### Environment Setup
- [ ] Flutter SDK installed (>= 3.0.0)
- [ ] Dart SDK installed (>= 3.0.0)
- [ ] Android Studio installed (for Android)
- [ ] Xcode installed (for iOS, macOS only)
- [ ] VS Code with Flutter extensions (recommended)
- [ ] Git installed

### Project Setup
- [ ] Clone repository
- [ ] Run `flutter pub get`
- [ ] Verify no dependency conflicts
- [ ] Check asset directories exist
- [ ] Verify pubspec.yaml configuration

### Code Quality
- [ ] Run `flutter analyze` - No errors/warnings
- [ ] Run `flutter test` - All tests pass
- [ ] Check code formatting with `dart format .`
- [ ] Review TODO comments in code
- [ ] Remove debug print statements
- [ ] Remove commented-out code

### Configuration
- [ ] Update app version in `pubspec.yaml`
- [ ] Verify app name and description
- [ ] Update server URL in `lib/config/constants.dart`
- [ ] Check all API endpoints
- [ ] Verify timeout configurations
- [ ] Update changelog

### Android Specific
- [ ] Update `android/app/build.gradle`:
  - [ ] `versionCode` and `versionName`
  - [ ] `compileSdkVersion` (latest stable)
  - [ ] `minSdkVersion` (21+)
  - [ ] `targetSdkVersion` (latest stable)
- [ ] Check AndroidManifest.xml:
  - [ ] Internet permission
  - [ ] Storage permissions
  - [ ] Network state permission
- [ ] Update app icon (`android/app/src/main/res/mipmap-*/ic_launcher.png`)
- [ ] Update splash screen if needed
- [ ] Configure signing keys (for release)
- [ ] Test on different Android versions

### iOS Specific (if applicable)
- [ ] Update `ios/Runner/Info.plist`:
  - [ ] Version number
  - [ ] Build number
- [ ] Update deployment target
- [ ] Configure signing certificates
- [ ] Update app icon
- [ ] Test on different iOS versions

### Features Testing
- [ ] App launches successfully
- [ ] Splash screen displays
- [ ] Home screen loads content
- [ ] Search functionality works
- [ ] Filters apply correctly
- [ ] Category browsing works
- [ ] Detail screen displays information
- [ ] Download starts and progresses
- [ ] Download pause/resume works
- [ ] Download cancel works
- [ ] Settings save and load
- [ ] Dark mode toggles
- [ ] Sync functionality works
- [ ] Offline mode works
- [ ] Error states display correctly
- [ ] Empty states display correctly

### UI/UX Testing
- [ ] All screens render correctly
- [ ] Text doesn't overflow
- [ ] Images load properly
- [ ] Animations are smooth
- [ ] Navigation works correctly
- [ ] Back button works
- [ ] Bottom navigation works
- [ ] Pull-to-refresh works
- [ ] Loading indicators display
- [ ] Toast messages appear
- [ ] Dialogs work correctly

### Performance Testing
- [ ] App starts in < 3 seconds
- [ ] Screens load in < 2 seconds
- [ ] Scrolling is smooth (60fps)
- [ ] No memory leaks
- [ ] Images are cached
- [ ] Network calls are efficient
- [ ] Battery usage is reasonable
- [ ] App size is optimized

### Network Testing
- [ ] Works on WiFi
- [ ] Works on mobile data
- [ ] Handles no connection gracefully
- [ ] Handles slow connection
- [ ] Reconnects after connection loss
- [ ] Timeout errors handled

### Edge Cases
- [ ] Empty content list
- [ ] Very long titles
- [ ] Special characters in text
- [ ] No search results
- [ ] Download fails
- [ ] Server unavailable
- [ ] Invalid data from server
- [ ] Storage full

### Security
- [ ] No hardcoded secrets
- [ ] API keys secured
- [ ] Permissions are necessary
- [ ] Data stored securely
- [ ] Network calls use HTTPS
- [ ] Input validation implemented

### Documentation
- [ ] README.md is up to date
- [ ] CHANGELOG.md updated
- [ ] Installation instructions clear
- [ ] Features documented
- [ ] API documentation complete
- [ ] Code comments where needed
- [ ] Contributing guidelines

### Build Verification
- [ ] Debug build works
- [ ] Release build works
- [ ] APK size is acceptable
- [ ] App bundle builds (Play Store)
- [ ] No build warnings
- [ ] Build scripts work

## Release Process

### 1. Version Bump
```bash
# Update pubspec.yaml
version: 1.0.0+1  # version+build_number

# Update CHANGELOG.md with new version
```

### 2. Create Release Build
```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (macOS only)
flutter build ios
```

### 3. Test Release Build
```bash
# Install on device
flutter install

# Or manually install APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 4. Create Git Tag
```bash
git add .
git commit -m "release: v1.0.0"
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin main --tags
```

### 5. Publish

#### Google Play Store
- [ ] Create release in Play Console
- [ ] Upload app bundle
- [ ] Fill release notes
- [ ] Set up staged rollout (10%, 20%, 50%, 100%)
- [ ] Monitor crashes and ANRs

#### GitHub Releases
- [ ] Create release on GitHub
- [ ] Add release notes
- [ ] Attach APK files
- [ ] Mark as latest release

#### F-Droid (if applicable)
- [ ] Submit to F-Droid repository
- [ ] Provide metadata
- [ ] Wait for review

### 6. Post-Release
- [ ] Monitor crash reports
- [ ] Check user feedback
- [ ] Update website/documentation
- [ ] Announce release
- [ ] Prepare hotfix if needed

## Hotfix Process

If critical issues found after release:

1. **Identify Issue**
   - Review crash reports
   - Reproduce the bug
   - Identify root cause

2. **Fix Issue**
   - Create hotfix branch
   - Implement fix
   - Test thoroughly

3. **Release Hotfix**
   - Bump patch version (1.0.1)
   - Build release
   - Test
   - Deploy

4. **Communicate**
   - Update changelog
   - Notify users
   - Document issue

## Rollback Process

If critical issues require rollback:

1. **Stop Rollout**
   - Pause Play Store rollout
   - Remove from distribution

2. **Previous Version**
   - Re-enable previous version
   - Or build emergency release

3. **Communicate**
   - Notify users
   - Explain situation

## Quality Gates

### Must Pass Before Release
- ✅ All tests pass
- ✅ No analyzer errors
- ✅ Critical features work
- ✅ No critical bugs
- ✅ Performance acceptable
- ✅ Security reviewed

### Should Pass
- ⭕ All features work
- ⭕ Good performance
- ⭕ Good battery usage
- ⭕ Positive user testing

### Nice to Have
- 🔹 All edge cases handled
- 🔹 Perfect performance
- 🔹 Comprehensive documentation

## Release Template

### Release Notes Template
```markdown
## [Version] - YYYY-MM-DD

### Added
- New feature 1
- New feature 2

### Changed
- Improvement 1
- Improvement 2

### Fixed
- Bug fix 1
- Bug fix 2

### Known Issues
- Issue 1 (workaround)
- Issue 2

### Upgrade Notes
- Any special instructions
```

## Monitoring

### After Release
- Monitor Firebase Crashlytics
- Check Google Play Console ANRs
- Review user feedback
- Track download numbers
- Monitor server load

### Metrics to Watch
- Crash-free users rate (>99%)
- ANR rate (<0.5%)
- User retention
- Download velocity
- Rating trends

---

**Release Manager**: [Name]
**Release Date**: [Date]
**Version**: [Version]

---

*Last Updated: March 2024*
