# Quick Start Guide - Health App

## Fastest Way to Run This App

### Step 1: Install Flutter (if not already installed)

**macOS:**
```bash
brew install --cask flutter
```

**Verify installation:**
```bash
flutter doctor
```

### Step 2: Navigate to Project Directory
```bash
cd /Users/apple/Documents/health_app-master
```

### Step 3: Install Dependencies
```bash
flutter pub get
```

### Step 4: Run the App
```bash
flutter run -d chrome
```

That's it! The app should now open in Chrome.

---

## What You Just Did

1. Installed Flutter framework on your system
2. Installed all required packages for the Health App
3. Launched the app in your web browser

---

## Next Steps

### First Time Using the App?
1. Click "Create an Account" on the welcome screen
2. Choose whether you're a **Doctor** or **Patient**
3. Fill in your details and sign up
4. Start exploring the features!

### Key Features to Try:
- **For Patients:**
  - Search for doctors by specialty
  - Book appointments
  - Chat with doctors
  - View appointment history

- **For Doctors:**
  - Manage your profile
  - View patient appointments
  - Chat with patients
  - Update availability

---

## Common Commands

**Hot Reload (while app is running):**
- Press `r` to reload changes instantly

**Restart App:**
- Press `R` for full restart

**Stop App:**
- Press `q` to quit

**Check Flutter Installation:**
```bash
flutter doctor
```

**Clean Build (if you encounter errors):**
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

---

## Available Platforms

Run on different platforms:

```bash
# Web (Chrome)
flutter run -d chrome

# Android (with emulator or device connected)
flutter run -d android

# iOS (macOS only, with simulator)
flutter run -d ios

# Check available devices
flutter devices
```

---

## Troubleshooting

**App won't start?**
1. Make sure Chrome is installed
2. Check internet connection (Firebase needs it)
3. Run `flutter clean && flutter pub get`
4. Try again with `flutter run -d chrome`

**Need more help?**
- Check the main README.md for detailed instructions
- Run `flutter doctor` to diagnose issues
- Make sure you're using Flutter 3.0 or higher

---

## Project Information

- **Framework:** Flutter 3.38.2
- **Language:** Dart
- **Backend:** Firebase
- **Platforms:** Web, Android, iOS

Enjoy using the Health App!
