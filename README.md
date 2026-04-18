# Fliser - Healthcare App

## Overview

Fliser is a comprehensive cross-platform healthcare application built with Flutter, designed to bridge the gap between patients and healthcare providers. The app facilitates seamless communication, appointment scheduling, and health management through an intuitive and secure platform. Whether you're a patient seeking medical advice or a doctor managing consultations, Fliser provides all the necessary tools for efficient healthcare delivery.

## Key Features

### For Patients
- **User Registration and Authentication**: Secure sign-up and login using Firebase Authentication.
- **Doctor Search and Discovery**: Browse and search for doctors based on specialty, location, and availability.
- **Appointment Booking**: Schedule, reschedule, or cancel appointments with ease.
- **Real-time Chat**: Communicate instantly with doctors for consultations.
- **Video Calling**: Direct video calls for remote consultations.
- **Health Vitals Tracking**: Monitor and record personal health metrics.
- **Prescription Management**: View and manage prescriptions issued by doctors.
- **Appointment History**: Access past appointments and medical records.

### For Doctors
- **Profile Management**: Create and update professional profiles with specialties and credentials.
- **Patient Management**: View patient details, appointment history, and health records.
- **Appointment Scheduling**: Manage availability and handle booking requests.
- **Real-time Communication**: Chat and video call with patients.
- **Prescription Issuance**: Create and send digital prescriptions.
- **Vital Monitoring**: Review patient health vitals and provide recommendations.

### General Features
- **Cross-Platform Support**: Runs on Android, iOS, and Web.
- **Offline Capabilities**: Basic functionality available without internet.
- **Secure Data Storage**: All data encrypted and stored securely using Firebase.
- **Push Notifications**: Receive updates on appointments and messages.
- **Multi-language Support**: Interface available in multiple languages (expandable).
- **Accessibility**: Designed with accessibility features for all users.

## Technology Stack

### Frontend
- **Flutter**: Cross-platform framework for building native interfaces.
- **Dart**: Programming language used for app logic.

### Backend & Services
- **Firebase**:
  - **Authentication**: User login and registration.
  - **Firestore**: NoSQL database for storing user data, appointments, and messages.
  - **Realtime Database**: For real-time chat functionality.
  - **Storage**: Cloud storage for images, documents, and media files.
  - **Cloud Messaging**: Push notifications.

### Additional Libraries
- **Provider**: State management for Flutter.
- **HTTP**: For API communications.
- **Image Picker**: For selecting and uploading images.
- **Shared Preferences**: Local data storage.
- **URL Launcher**: For opening external links.
- **Flutter Secure Storage**: Secure local storage for sensitive data.

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app_theme.dart               # App-wide theme and styling
├── constants/
│   └── api_constants.dart       # API endpoints and constants
├── helperFunction/              # Utility functions
├── models/                      # Data models
│   ├── appointment_model.dart   # Appointment data structure
│   ├── doctor_model.dart        # Doctor profile model
│   ├── message_model.dart       # Chat message model
│   ├── user_model.dart          # User data model
│   └── vital_model.dart         # Health vitals model
├── screens/                     # UI screens
│   ├── splash_screen.dart       # App splash screen
│   ├── auth/                    # Authentication screens
│   ├── chat/                    # Chat interface screens
│   ├── common/                  # Shared screens
│   ├── doctor/                  # Doctor-specific screens
│   └── patient/                 # Patient-specific screens
├── services/                    # Business logic and API calls
│   ├── api_client.dart          # HTTP client configuration
│   ├── appointment_service.dart # Appointment management
│   ├── auth_service.dart        # Authentication logic
│   ├── doctor_service.dart      # Doctor-related operations
│   ├── message_service.dart     # Chat and messaging
│   ├── prescription_service.dart# Prescription handling
│   └── vital_service.dart       # Health vitals service
└── widgets/                     # Reusable UI components
    ├── app_button.dart          # Custom button widget
    └── ...                      # Other widgets
```

## Installation and Setup

### Prerequisites
- Flutter SDK (version 3.0 or higher)
- Dart SDK (comes with Flutter)
- Android Studio or Xcode for platform-specific development
- Firebase account for backend services

### Steps

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd fliser-health-app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/).
   - Enable the following services:
     - Authentication
     - Firestore Database
     - Realtime Database
     - Storage
     - Cloud Messaging
   - Download configuration files:
     - `google-services.json` for Android (place in `android/app/`)
     - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
     - Update `web/index.html` with Firebase config for web.

4. **Run the App**
   - For Android:
     ```bash
     flutter run -d android
     ```
   - For iOS:
     ```bash
     flutter run -d ios
     ```
   - For Web:
     ```bash
     flutter run -d chrome
     ```

5. **Build for Production**
   - Android APK:
     ```bash
     flutter build apk --release
     ```
   - iOS:
     ```bash
     flutter build ios --release
     ```
   - Web:
     ```bash
     flutter build web --release
     ```

## API Documentation

The app uses RESTful APIs for certain operations. Key endpoints include:

- **Authentication**: `/auth/login`, `/auth/register`
- **Appointments**: `/appointments/book`, `/appointments/cancel`
- **Doctors**: `/doctors/search`, `/doctors/profile`
- **Messages**: `/messages/send`, `/messages/history`
- **Vitals**: `/vitals/record`, `/vitals/history`

All API calls are handled through the `ApiClient` service, which includes error handling and authentication headers.

## Security and Privacy

- **Data Encryption**: All sensitive data is encrypted in transit and at rest.
- **User Consent**: Explicit consent required for data collection.
- **Compliance**: Adheres to HIPAA and GDPR standards for health data.
- **Access Control**: Role-based access for patients and doctors.

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -m 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a pull request.

### Code Style
- Follow Dart's official style guide.
- Use `flutter format` for code formatting.
- Write tests for new features.

## Testing

Run tests with:
```bash
flutter test
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@fliser.com or join our community forum.

## Roadmap

- [ ] AI-powered symptom checker
- [ ] Integration with wearable devices
- [ ] Telemedicine regulations compliance
- [ ] Multi-language expansion
- [ ] Offline mode enhancements

---

Built with ❤️ using Flutter and Firebase.

#### Run on Connected Device
```bash
# Connect your device via USB
# Enable Developer Mode / USB Debugging

# Run the app
flutter run
```

### Hot Reload
While the app is running, you can make code changes and:
- Press `r` in the terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Build for Production

**Web:**
```bash
flutter build web
```
Output will be in `build/web/`

**Android APK:**
```bash
flutter build apk
```

**iOS (macOS only):**
```bash
flutter build ios
```

---

## Project Structure
```
lib/
├── main.dart                 # App entry point
├── model/                    # Data models
├── screens/                  # UI screens
│   ├── firebase_auth.dart   # Authentication
│   ├── patient/             # Patient-specific screens
│   └── doctor/              # Doctor-specific screens
└── widgets/                  # Reusable widgets
```

---

## Troubleshooting

**Issue: Flutter command not found**
- Make sure Flutter is added to your PATH
- Restart your terminal after installation

**Issue: Dependencies error**
```bash
flutter clean
flutter pub get
```

**Issue: Chrome not launching**
- Install Google Chrome
- Or run on a different device: `flutter run -d <device-id>`

**Issue: Firebase errors**
- Ensure Firebase is properly configured
- Check your internet connection
- Verify Firebase project settings

---

## Support
For issues and questions, please check:
- [Flutter Documentation](https://docs.flutter.dev)
- [Firebase Documentation](https://firebase.google.com/docs)
- Project issues on GitHub

---
<h1 align="center"> Thank You 😁😀</h1>
