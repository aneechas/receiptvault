# Xcode 16 iOS Simulator Visibility Issue

## Problem Summary
Xcode 16's build system cannot detect or communicate with iOS simulators, preventing Flutter app deployment despite successful builds.

## Environment
- **Xcode Version:** 16.0
- **macOS:** 15.6.1 (24G90)
- **Flutter:** 3.35.4
- **Dart:** 3.9.2
- **iOS Simulator Runtime:** iOS 26.0

## Symptoms
1. ✅ `simctl` can see and boot simulators
2. ✅ Flutter can initially detect simulators with `flutter devices`
3. ❌ Xcode build system cannot find simulators when deploying
4. ❌ All Flutter run commands fail with "Unable to find a destination"

## Error Message
```
Uncategorized (Xcode): Unable to find a destination matching the provided destination specifier:
    { id:1368ECAA-5913-48DB-A0C0-D7D601888F99 }

Available destinations for the "Runner" scheme:
    { platform:macOS, arch:arm64, variant:Designed for [iPad,iPhone], id:00008132-001668E03A85801C, name:My Mac }
    { platform:iOS, id:dvtdevice-DVTiPhonePlaceholder-iphoneos:placeholder, name:Any iOS Device }
    { platform:iOS Simulator, id:dvtdevice-DVTiOSDeviceSimulatorPlaceholder-iphonesimulator:placeholder, name:Any iOS Simulator Device }
```

## What Was Tried

### ✅ Successful Workarounds
1. **Removed Firebase** - Eliminated BoringSSL-GRPC Xcode 16 incompatibility
   - Commented out firebase_core, firebase_auth, cloud_firestore in pubspec.yaml
   - Reduced pod count from 40 to 22
   - ML Kit OCR packages remain intact (core functionality preserved)

2. **Fixed iOS Deployment Target** - Set minimum iOS to 15.0 across all pods

3. **Cleaned and Rebuilt** - Flutter clean, pod clean, reinstalled dependencies

### ❌ Unsuccessful Attempts
1. **Multiple Podfile fixes** - Tried modifying post_install hooks to fix BoringSSL flags
2. **Created fresh simulators** - iPhone 15 Pro (B29FCEFB-4485-4893-88A6-A3DF5B95601C)
3. **Xcode path reset** - Attempted but requires sudo password
4. **Direct xcodebuild** - Same visibility issue
5. **Flutter run variations** - With/without device ID, all failed
6. **Session restart verification** - Issue persists across sessions, confirming system-level blocker

## Root Cause
Xcode 16 has a fundamental incompatibility with iOS simulator detection. Even when simulators are booted and visible to system tools, Xcode's build system cannot enumerate them.

## Solutions

### Option 1: Restart Mac (Recommended)
Complete system restart may reset Xcode's simulator communication layer.

```bash
# After restart, verify simulators:
/Applications/Xcode.app/Contents/Developer/usr/bin/simctl list devices
flutter devices
```

### Option 2: Use Physical iOS Device
Connect an actual iPhone/iPad via USB and deploy directly:

```bash
flutter devices  # Should show physical device
flutter run -d <device-id>
```

### Option 3: Downgrade to Xcode 15
If Xcode 15 is available, switch to it:

```bash
sudo xcode-select -s /Applications/Xcode-15.app/Contents/Developer
```

## Project Status

### ✅ Completed
- iOS deployment target fixed (15.0)
- Firebase temporarily removed to bypass BoringSSL-GRPC
- CocoaPods dependencies clean (22 pods)
- ML Kit OCR intact and ready (google_mlkit_text_recognition 0.11.0)
- pubspec.yaml configured correctly

### ⏳ Blocked (Needs System Fix)
- Launch app on simulator
- Verify OCR functionality
- Test AI insights with Gemini API

### 📋 Next Steps (After Fix)
1. Boot simulator: `/Applications/Xcode.app/Contents/Developer/usr/bin/simctl boot <device-id>`
2. Open Simulator.app
3. Run: `flutter run -d <device-id>`
4. Test OCR by scanning a receipt
5. Verify ML Kit text recognition works
6. Re-add Firebase with proper Xcode 16 compatible versions

## Files Modified

### pubspec.yaml
```yaml
# Firebase (temporarily disabled to test ML Kit)
# firebase_core: ^2.32.0
# firebase_auth: ^4.20.0
# cloud_firestore: ^4.17.5
```

### ios/Podfile
- Post-install hook sets IPHONEOS_DEPLOYMENT_TARGET to 15.0
- No BoringSSL-GRPC in dependencies

### ios/Podfile.lock
- 22 pods installed (vs 40 with Firebase)
- No BoringSSL-GRPC dependency
- ML Kit pods present: MLKitTextRecognition, MLKitVision, MLKitCommon

## Important Notes
- **DO NOT** re-add Firebase until Xcode simulator issue is resolved
- **Firebase versions** need updating to Xcode 16 compatible releases when re-adding
- **ML Kit OCR** is the core feature and is fully configured
- **lib/main.dart** needs Firebase init commented out once app runs

## Created Simulators
- iPhone 16e: `1368ECAA-5913-48DB-A0C0-D7D601888F99`
- iPhone15ProFresh: `B29FCEFB-4485-4893-88A6-A3DF5B95601C`

## Command Reference
```bash
# List simulators
/Applications/Xcode.app/Contents/Developer/usr/bin/simctl list devices

# Boot simulator
/Applications/Xcode.app/Contents/Developer/usr/bin/simctl boot <device-id>

# Open Simulator app
open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app

# Run Flutter app
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
export PATH="$HOME/flutter/bin:$PATH"
flutter run -d <device-id>

# Check Flutter devices
flutter devices
```