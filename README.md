# CareSync

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-2E7D32)
![Status](https://img.shields.io/badge/Status-Active%20Development-00897B)

CareSync is a role-based healthcare management application built with Flutter and Firebase. It supports patients, doctors, and administrators in one connected workflow for registration, authentication, appointments, prescriptions, lab tests, support, reporting, and reminders.

## Overview

| Item            | Details                                                    |
| --------------- | ---------------------------------------------------------- |
| App name        | CareSync                                                   |
| Package name    | healthcare_system                                          |
| Framework       | Flutter                                                    |
| Backend         | Firebase Authentication, Cloud Firestore, Firebase Storage |
| Notifications   | Flutter Local Notifications, timezone                      |
| Payments        | Razorpay                                                   |
| Supported roles | Patient, Doctor, Admin                                     |

## Key Features

### Patient Experience

- Secure sign in with email/password or Google Sign-In.
- Patient dashboard with quick access to appointments, reports, prescriptions, and profile data.
- Appointment booking and medical history tracking.
- Upload and view reports, prescriptions, and lab test records.
- Live chat and support request flow.
- BMI calculator and health utilities.
- Lab test payment and payment gateway support.
- Local reminders for medication and prescriptions.

### Doctor Workflow

- Doctor dashboard with appointment and patient insights.
- View and manage patient appointments.
- Review patient history and reports.
- Create and manage prescriptions.
- Order lab tests for patients.
- Access doctor-specific patient records and schedules.

### Admin Controls

- Admin dashboard for system-level overview.
- Manage doctors, staff, and patients.
- Approve requests and handle onboarding flows.
- Oversee laboratory tests and pending lab orders.
- Review and reply to support chats.
- Access reports, settings, and doctor schedules.

## Authentication and Demo Credentials

The app includes example login credentials for testing and demo access.

| Role    | Email                 | Password      | Notes                                      |
| ------- | --------------------- | ------------- | ------------------------------------------ |
| Admin   | admin@healthcare.com  | adminpassword | Seed admin account used in the app         |
| Doctor  | abc18718333@gmail.com | abc1234       | Example doctor login provided for testing  |
| Patient | pyadav@gmail.com      | pyadav123     | Example patient login provided for testing |

If you are sharing this repository publicly, consider rotating or replacing demo credentials before release.

## Technology Stack

| Category          | Packages / Tools                                                                         |
| ----------------- | ---------------------------------------------------------------------------------------- |
| UI                | Flutter, Material Design, google_fonts                                                   |
| Auth              | firebase_auth, google_sign_in                                                            |
| Database          | cloud_firestore                                                                          |
| Storage           | firebase_storage, file_picker, image_picker                                              |
| Notifications     | flutter_local_notifications, timezone                                                    |
| PDFs and printing | pdf, printing                                                                            |
| Payments          | razorpay_flutter                                                                         |
| Utilities         | intl, shared_preferences, permission_handler, url_launcher, qr_flutter, health, fl_chart |

## Project Structure

| Path                          | Purpose                                                                           |
| ----------------------------- | --------------------------------------------------------------------------------- |
| lib/main.dart                 | App bootstrap, Firebase initialization, notifications, and timezone setup         |
| lib/login_page.dart           | Authentication screen and Google Sign-In                                          |
| lib/splash_screen.dart        | Initial routing and role-based navigation                                         |
| lib/role_selection_page.dart  | Manual role selection screen                                                      |
| lib/screens/patient/          | Patient dashboards, appointments, reports, labs, support, and profile pages       |
| lib/screens/doctor/           | Doctor dashboard, patient management, prescriptions, and lab ordering pages       |
| lib/screens/admin/            | Admin dashboard, approvals, user management, lab management, support, and reports |
| lib/notification_service.dart | Notification setup and reminder handling                                          |
| assets/images/                | App images and branding assets                                                    |

## Prerequisites

- Flutter SDK 3.1.3 or later.
- Dart 3.1.3 or later.
- Android Studio, VS Code, or another Flutter-compatible IDE.
- Firebase project configured for Authentication, Firestore, and Storage.
- Google Sign-In configuration for the target platforms.
- Razorpay credentials if you plan to test payment flows.

## Setup

1. Clone or open the project in your editor.
2. Install Flutter dependencies:

```bash
flutter pub get
```

3. Make sure lib/firebase_options.dart matches your Firebase project.
4. Confirm your Firebase app configuration files are present:
   - android/app/google-services.json
   - iOS Firebase configuration, if you are building for Apple platforms
5. If you use Google Sign-In on Android, verify your SHA-1 fingerprint in Firebase Console.
6. If you use Google Sign-In on Windows or Web, ensure OAuth client IDs are configured correctly.

## Run the App

### Development

```bash
flutter run
```

### Useful Commands

| Command           | Purpose                           |
| ----------------- | --------------------------------- |
| flutter pub get   | Install project dependencies      |
| flutter run       | Launch the app in debug mode      |
| flutter analyze   | Check for Dart and Flutter issues |
| flutter test      | Run widget and unit tests         |
| flutter build apk | Build an Android release APK      |
| flutter build web | Build the web release output      |

## Firebase Notes

CareSync uses Firebase for authentication and data storage. Before running the app, make sure the following are configured in your Firebase project:

- Authentication providers enabled for Email/Password and Google Sign-In.
- Cloud Firestore collections for users, appointments, prescriptions, reports, chats, and lab data.
- Firebase Storage rules for uploaded reports and images.

## Notifications

- The app initializes local notifications at startup.
- Timezone is set to Asia/Kolkata for reminder scheduling.
- Notification permission is requested on supported platforms.

## Assets

The following branded assets are registered in the project:

- assets/images/hospital_logo.png
- assets/images/doctor_signature.png
- assets/images/patient_profile.png

## Screens at a Glance

| Area    | Representative Screens                                                                              |
| ------- | --------------------------------------------------------------------------------------------------- |
| Patient | Home, appointments, reports, prescriptions, profile, medical history, lab tests, live chat, support |
| Doctor  | Dashboard, appointments, patients, patient history, prescriptions, reports, lab ordering            |
| Admin   | Dashboard, user management, approvals, laboratory, support chats, reports, settings                 |

## Troubleshooting

| Issue                       | Suggested Fix                                                |
| --------------------------- | ------------------------------------------------------------ |
| Login fails                 | Verify Firebase Auth setup and test credentials              |
| Google Sign-In fails        | Check OAuth client IDs and SHA-1 fingerprints                |
| Notifications do not appear | Confirm notification permission and platform support         |
| Firebase errors             | Re-check lib/firebase_options.dart and platform config files |
| Payment flow fails          | Validate Razorpay keys and environment settings              |

## Contributing

1. Create a feature branch.
2. Make focused, minimal changes.
3. Run flutter analyze and relevant tests before opening a pull request.
4. Update this README if the user flow, setup steps, or credentials change.

## Support

For maintenance or onboarding, keep the demo credentials section updated and ensure Firebase configuration files stay aligned with the active project environment.
