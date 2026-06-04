# CareSync

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase&logoColor=black)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows-2E7D32)
![Status](https://img.shields.io/badge/Status-Active%20Development-00897B)

CareSync is a role-based healthcare management app built with Flutter and Firebase. It connects patients, doctors, and administrators in one workflow for sign-in, appointments, prescriptions, lab tests, reports, support, notifications, and payments.

## Project Overview

| Item            | Details                                                    |
| --------------- | ---------------------------------------------------------- |
| App name        | CareSync                                                   |
| Package name    | healthcare_system                                          |
| Framework       | Flutter                                                    |
| Backend         | Firebase Authentication, Cloud Firestore, Firebase Storage |
| Notifications   | Flutter Local Notifications, timezone                      |
| Payments        | Razorpay                                                   |
| Supported roles | Patient, Doctor, Admin                                     |

## How The App Works

1. The app starts from [lib/main.dart](lib/main.dart) and initializes Firebase, notifications, and timezone settings.
2. The splash screen checks whether a user is already signed in and redirects to the correct page.
3. If the user is not signed in, the app opens the login page.
4. After sign-in, the app reads the user's role from Firestore and opens the matching dashboard.
5. Each role gets its own set of pages for daily operations like appointments, reports, prescriptions, lab handling, and support.

## Demo Login Credentials

Use these credentials for testing the app locally.

| Role    | Email                 | Password      | Notes                  |
| ------- | --------------------- | ------------- | ---------------------- |
| Admin   | admin@healthcare.com  | adminpassword | Admin dashboard access |
| Doctor  | abc18718333@gmail.com | abc1234       | Doctor demo account    |
| Patient | pyadav@gmail.com      | pyadav123     | Patient demo account   |

If you plan to publish this project publicly, replace these demo credentials with your own test accounts.

## Features

### Patient Flow

- Sign in with email/password or Google Sign-In.
- View dashboard, profile, appointments, prescriptions, reports, lab tests, and medical history.
- Upload reports and manage personal health records.
- Use support chat, live chat, BMI calculator, and payment flow for lab tests.
- Receive local reminders and notifications.

### Doctor Flow

- View doctor dashboard with appointment status and patient insights.
- Confirm appointments and review patient data.
- Create prescriptions and order lab tests.
- Check reports, appointment summaries, and patient history.
- Access notifications and sign out securely.

### Admin Flow

- View overall system dashboard and counts of users and lab orders.
- Manage doctors, patients, and staff.
- Approve requests and review onboarding flows.
- Manage laboratory pages and support chat replies.
- Open settings, reports, and schedule-related screens.

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

| Path                                                                     | Purpose                                                                                                             |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- |
| [lib/main.dart](lib/main.dart)                                           | App bootstrap, Firebase init, notification setup, timezone init                                                     |
| [lib/splash_screen.dart](lib/splash_screen.dart)                         | Animated launch screen and auto-routing based on login state                                                        |
| [lib/login_page.dart](lib/login_page.dart)                               | Email/password login, Google Sign-In, and forgot password flow                                                      |
| [lib/role_selection_page.dart](lib/role_selection_page.dart)             | Manual role selection screen                                                                                        |
| [lib/app_drawer.dart](lib/app_drawer.dart)                               | App drawer and navigation helpers                                                                                   |
| [lib/notification_service.dart](lib/notification_service.dart)           | Local notification scheduling and reminder handling                                                                 |
| [lib/notification_page.dart](lib/notification_page.dart)                 | Notification UI                                                                                                     |
| [lib/patient_registration_page.dart](lib/patient_registration_page.dart) | Patient registration form                                                                                           |
| [lib/screens/patient/](lib/screens/patient)                              | Patient pages such as home, appointments, reports, prescriptions, support, lab tests, payment, profile, and history |
| [lib/screens/doctor/](lib/screens/doctor)                                | Doctor pages such as dashboard, appointments, patients, history, prescriptions, reports, and lab ordering           |
| [lib/screens/admin/](lib/screens/admin)                                  | Admin pages such as dashboard, user management, approvals, staff, lab management, support, reports, and settings    |
| [assets/images/](assets/images)                                          | Branding and profile images                                                                                         |

## Screen Breakdown

### Patient Screens

- Home page
- Appointment booking
- BMI calculator
- Lab payment and payment gateway
- Live chat and support
- My lab tests
- Patient details, profile, edit profile, and medical history
- Prescription and report pages

### Doctor Screens

- Doctor dashboard
- Doctor appointments
- Patient list and patient history
- Doctor prescriptions
- Doctor reports
- Lab test ordering

### Admin Screens

- Admin dashboard
- Manage doctors, patients, and staff
- Add and edit doctor/staff flows
- Approve requests
- Laboratory management and pending orders
- Support chat list and reply pages
- Admin reports and settings

## Prerequisites

- Flutter SDK 3.1.3 or later.
- Dart 3.1.3 or later.
- Android Studio, VS Code, or another Flutter-compatible IDE.
- Firebase project configured for Authentication, Firestore, and Storage.
- Google Sign-In configuration for the target platforms.
- Razorpay keys if you want to test payment flows.

## Setup

1. Clone or open the project in your editor.
2. Install dependencies.

```bash
flutter pub get
```

3. Make sure [lib/firebase_options.dart](lib/firebase_options.dart) matches your Firebase project.
4. Confirm the required Firebase config files are present:
   - android/app/google-services.json
   - iOS Firebase config if you are building for Apple platforms
5. If you use Google Sign-In on Android, verify the SHA-1 fingerprint in Firebase Console.
6. If you use Google Sign-In on Windows or Web, configure the OAuth client IDs correctly.

## Run The App

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

CareSync uses Firebase for authentication and data storage. Before running the app, make sure the following are configured:

- Authentication providers enabled for Email/Password and Google Sign-In.
- Firestore collections for users, appointments, prescriptions, reports, chats, and lab data.
- Firebase Storage rules for uploaded reports and images.

## Notifications

- The app initializes local notifications at startup.
- Timezone is set to Asia/Kolkata for reminder scheduling.
- Notification permission is requested on supported platforms.

## Assets

The following assets are registered in the project:

- assets/images/hospital_logo.png
- assets/images/doctor_signature.png
- assets/images/patient_profile.png

## Troubleshooting

| Issue                       | Suggested Fix                                                                             |
| --------------------------- | ----------------------------------------------------------------------------------------- |
| Login fails                 | Verify Firebase Auth setup and the demo credentials above                                 |
| Google Sign-In fails        | Check OAuth client IDs and SHA-1 fingerprints                                             |
| Notifications do not appear | Confirm notification permission and platform support                                      |
| Firebase errors             | Re-check [lib/firebase_options.dart](lib/firebase_options.dart) and platform config files |
| Payment flow fails          | Validate Razorpay keys and environment settings                                           |

## Contributing

1. Create a feature branch.
2. Make focused, minimal changes.
3. Run `flutter analyze` and relevant tests before opening a pull request.
4. Update this README if the user flow, setup steps, or credentials change.

## Support

For onboarding or maintenance, keep the demo credentials section updated and ensure Firebase configuration stays aligned with the active environment.
