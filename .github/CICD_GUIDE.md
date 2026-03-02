## 🚀 Visuales UCLV - CI/CD Guide

This document explains the Continuous Integration and Continuous Deployment (CI/CD) setup for Visuales UCLV.

---

## 📋 **CI/CD Overview**

The project uses **GitHub Actions** for automated building, testing, and releasing.

### **Workflows Available**

| Workflow | File | Trigger | Purpose |
|----------|------|---------|---------|
| Android Build | `android_build.yml` | Push to main/master/develop | Auto-build on every push |
| Manual Release | `manual_release.yml` | Manual trigger | Create releases on demand |
| Tests & Quality | `tests.yml` | Push/PR | Run tests and quality checks |

---

## 🔧 **Workflow Details**

### 1. **Android Build CI** (`android_build.yml`)

**Triggers:**
- Push to `main`, `master`, or `develop` branches
- Pull requests to these branches

**What it does:**
1. ✅ Checks out code
2. ☕ Sets up Java 17
3. 📱 Sets up Flutter 3.19.0
4. 📦 Installs dependencies
5. 🔍 Analyzes code
6. 🧪 Runs tests
7. 🔨 Builds Debug APK
8. 🚀 Builds Release APK
9. 📦 Builds App Bundle (Play Store)
10. ⬆️ Uploads artifacts
11. 🎉 Creates GitHub Release (only on main branch push)

**Artifacts Generated:**
- Debug APK (7 days retention)
- Release APK (30 days retention)
- App Bundle (30 days retention)

**Auto-Release:**
- Creates GitHub Release on main branch push
- Tags version as `v{build_number}`
- Includes download links

---

### 2. **Manual Release Build** (`manual_release.yml`)

**Triggers:**
- Manual trigger from GitHub Actions tab

**Inputs:**
- `version`: Version number (e.g., 1.0.0)
- `release_type`: release/debug/beta
- `create_release`: Create GitHub Release (true/false)

**What it does:**
1. All steps from Android Build CI
2. Updates pubspec.yaml version
3. Creates formatted GitHub Release
4. Uploads all APK variants

**When to use:**
- Creating a new version
- Testing specific builds
- Beta releases

---

### 3. **Tests & Quality CI** (`tests.yml`)

**Triggers:**
- Push to main/master/develop
- Pull requests

**What it does:**
1. Runs all tests with coverage
2. Uploads coverage to Codecov
3. Runs flutter analyze
4. Checks code formatting

**When it runs:**
- Every push to main branches
- Every pull request

---

## 📱 **How to Use**

### **Automatic Builds**

Just push to main/master/develop:

```bash
git add .
git commit -m "feat: new feature"
git push origin main
```

GitHub Actions will:
- Build the app
- Run tests
- Create release (if on main)

### **Manual Release**

1. Go to **Actions** tab in GitHub
2. Select **"Manual Release Build"**
3. Click **"Run workflow"**
4. Fill in:
   - Version: `1.0.0`
   - Release type: `release`
   - Create Release: `true`
5. Click **"Run workflow"**

---

## 🔐 **Signing Configuration**

### **For Google Play Store**

You need to configure signing in `android/key.properties`:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=<your-key-alias>
storeFile=<path-to-keystore>
```

**Create keystore:**
```bash
keytool -genkey -v -keystore visuales-uclv.keystore -alias visuales-uclv -keyalg RSA -keysize 2048 -validity 10000
```

**Add to .gitignore:**
```
android/key.properties
android/*.keystore
```

**Store secrets in GitHub:**
1. Go to Repository Settings → Secrets and variables → Actions
2. Add:
   - `ANDROID_KEYSTORE`: Base64 encoded keystore
   - `KEYSTORE_PASSWORD`: Store password
   - `KEY_ALIAS`: Key alias
   - `KEY_PASSWORD`: Key password

---

## 📊 **Build Outputs**

### **APK Files**

Location: `build/app/outputs/flutter-apk/`

| File | Architecture | Size | Use |
|------|-------------|------|-----|
| `app-armeabi-v7a-release.apk` | 32-bit ARM | ~50MB | Most devices |
| `app-arm64-v8a-release.apk` | 64-bit ARM | ~55MB | Modern devices |
| `app-x86_64-release.apk` | 64-bit x86 | ~55MB | Emulators |

### **App Bundle**

Location: `build/app/outputs/bundle/release/app-release.aab`

- Size: ~60MB
- For Google Play Store
- Dynamic delivery (smaller downloads)

---

## 🎯 **Release Process**

### **Automated (Push to main)**

```
1. Developer pushes to main
2. GitHub Actions builds
3. Tests run
4. Release created automatically
5. APK available for download
```

### **Manual (Specific version)**

```
1. Developer triggers manual workflow
2. Specifies version (e.g., 1.0.0)
3. Builds release APK
4. Creates formatted release
5. Uploads to GitHub Releases
```

---

## 📝 **Version Management**

### **Semantic Versioning**

Format: `MAJOR.MINOR.PATCH+BUILD`

Examples:
- `1.0.0+1` - First release
- `1.0.1+2` - Bug fix
- `1.1.0+10` - New features
- `2.0.0+1` - Major changes

### **Update Version**

**Manual:**
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

**Automated (in workflow):**
```yaml
version: ${{ inputs.version }}+${{ github.run_number }}
```

---

## 🔍 **Monitoring Builds**

### **GitHub Actions Tab**

1. Go to repository
2. Click **Actions** tab
3. See all workflow runs
4. Click on specific run for details
5. Download artifacts

### **Build Status Badges**

Add to README.md:

```markdown
[![Android Build](https://github.com/your-user/visuales-uclv/actions/workflows/android_build.yml/badge.svg)](https://github.com/your-user/visuales-uclv/actions/workflows/android_build.yml)
[![Tests](https://github.com/your-user/visuales-uclv/actions/workflows/tests.yml/badge.svg)](https://github.com/your-user/visuales-uclv/actions/workflows/tests.yml)
```

---

## ⚠️ **Troubleshooting**

### **Build Fails**

1. Check Actions log for errors
2. Verify Flutter version
3. Check dependencies
4. Run locally: `flutter build apk --release`

### **Tests Fail**

1. Check test output in Actions
2. Run locally: `flutter test`
3. Fix failing tests
4. Push again

### **Release Not Created**

1. Check if on main branch
2. Verify GITHUB_TOKEN permissions
3. Check workflow run logs
4. Manual trigger if needed

---

## 🚀 **Advanced Configuration**

### **Custom Flutter Version**

Edit workflow files:
```yaml
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.19.0'  # Change version
```

### **Add More Tests**

Add to `tests.yml`:
```yaml
- name: Run integration tests
  run: flutter test integration_test/
```

### **Deploy to Play Store**

Add step after build:
```yaml
- name: Upload to Play Store
  uses: r0adkll/upload-google-play@v1
  with:
    serviceAccountJsonPlainText: ${{ secrets.PLAY_STORE_SERVICE_ACCOUNT }}
    packageName: com.example.visuales
    releaseFiles: build/app/outputs/bundle/release/app-release.aab
    track: internal
```

---

## 📊 **Build History**

View all builds:
- **Actions** tab → Select workflow → See runs

View artifacts:
- Click on workflow run → Scroll to "Artifacts"

View releases:
- **Releases** tab → See all releases

---

## 🎉 **Summary**

| Feature | Status |
|---------|--------|
| Auto Build on Push | ✅ |
| Auto Tests | ✅ |
| Auto Release | ✅ |
| Manual Release | ✅ |
| Code Coverage | ✅ |
| Multiple APKs | ✅ |
| App Bundle | ✅ |

---

**Last Updated**: March 2024  
**Version**: 1.0.0

---

**Happy Building! 🚀**
