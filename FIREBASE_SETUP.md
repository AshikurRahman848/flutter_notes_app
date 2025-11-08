# Detailed Firebase Setup Guide

This document provides a step-by-step guide to setting up the Firebase backend for the Flutter Notes App.

## 1. Create a Firebase Project

1.  Navigate to the **[Firebase Console](https://console.firebase.google.com/)**.
2.  Click **Add project** and follow the on-screen instructions to create a new project.
3.  Give your project a meaningful name (e.g., `Flutter-Notes-App-Test`).

## 2. Enable Firebase Services

### 2.1. Enable Authentication (Email/Password)

1.  In the Firebase Console, navigate to **Build** > **Authentication**.
2.  Click **Get started**.
3.  Go to the **Sign-in method** tab.
4.  Click on **Email/Password** and toggle the switch to **Enable** it.
5.  Click **Save**.

### 2.2. Set up Cloud Firestore

1.  In the Firebase Console, navigate to **Build** > **Firestore Database**.
2.  Click **Create database**.
3.  Select **Start in production mode** (or test mode if you prefer, but production mode is recommended for a test submission).
4.  Choose a location for your Firestore data.
5.  Click **Enable**.

#### Firestore Security Rules (secure)

To ensure users can only create/read/update/delete their own notes, use the rules below. They
require that:

- The client is authenticated for any operation.
- A note's `userId` must match the authenticated user's UID for read/update/delete.
- When creating a note, the supplied `userId` must match the current auth UID (prevents creating
  notes on behalf of other users).

1. In the Firestore Database section, go to the **Rules** tab.
2. Replace the existing rules with the following and **Publish**:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notes/{noteId} {
      // Only authenticated users may create notes and the note must belong to them
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid
        && request.resource.data.keys().hasAll(['content','userId','createdAt','updatedAt']);

      // Only the owner can read their note
      allow read: if request.auth != null
        && resource.data.userId == request.auth.uid;

      // Only the owner can update or delete their note
      allow update, delete: if request.auth != null
        && resource.data.userId == request.auth.uid
        && request.resource.data.userId == request.auth.uid;
    }
  }
}
```

Notes:
- The `hasAll([...])` check on create is optional but helps ensure required fields are present.
- These rules prevent any authenticated user from reading or modifying another user's notes.

3. Test your rules with the Firebase Emulator or the Firestore Rules Simulator.

Security reminders
- Do NOT commit service-account JSON files or other server-side secrets into the repository.
- Consider enabling Firebase App Check to reduce risk of backend abuse from forged clients.
- Optionally restrict API key usage in the Google Cloud Console for additional safety.

## 3. Connect Flutter App to Firebase

### 3.1. Install Firebase CLI

If you haven't already, install the Firebase CLI:

```bash
npm install -g firebase-tools
```

Then, log in:

```bash
firebase login
```

### 3.2. Configure Flutter Project

1.  Open your terminal in the root directory of the `flutter_notes_app` project.
2.  Run the configuration command:

    ```bash
    flutterfire configure
    ```

3.  Follow the prompts:
    *   Select your Firebase project.
    *   Select the platforms you want to support (e.g., `android`, `ios`, `web`).
    *   The CLI will automatically generate the `lib/firebase_options.dart` file with your project's unique configuration.

### 3.3. Final Check

Ensure the following dependencies are in your `pubspec.yaml` (they are already included in the provided code):

```yaml
dependencies:
  # ... other dependencies
  firebase_core: ^2.0.0 # Or latest version
  firebase_auth: ^4.0.0 # Or latest version
  cloud_firestore: ^4.0.0 # Or latest version
```

You are now ready to run the application with a fully configured Firebase backend.
