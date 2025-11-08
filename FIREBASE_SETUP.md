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

#### Firestore Security Rules

To ensure users can only read and write their own notes, you must set up the following security rules.

1.  In the Firestore Database section, go to the **Rules** tab.
2.  Replace the existing rules with the following:

    ```firestore
    rules_version = '2';
    service cloud.firestore {
      match /databases/{database}/documents {
        // Allow read/write access to notes only if the user is authenticated
        // and the note's 'userId' field matches the authenticated user's UID.
        match /notes/{noteId} {
          allow read, create: if request.auth != null;
          allow update, delete: if request.auth != null && request.resource.data.userId == request.auth.uid;
        }
      }
    }
    ```

    **Note:** The `create` rule is set to `if request.auth != null` to allow any authenticated user to create a note. The `update` and `delete` rules are stricter, ensuring the user ID in the note matches the authenticated user's ID.

3.  Click **Publish**.

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
