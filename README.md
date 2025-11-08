# Flutter Notes App: Firebase + Provider

This project is a small, clean, and production-ready Flutter application designed to demonstrate best practices in state management, project structure, and Firebase integration. It serves as a comprehensive solution for a developer test submission, focusing on **clean code**, **correct Firebase usage**, and **proper Provider state management**.

## 📋 Features

The application allows users to:

*   **Authentication:** Sign up and log in using **Firebase Authentication** (Email/Password).
*   **State Persistence:** Maintain the logged-in state across app restarts.
*   **Notes Management:** Add, view, and delete personal notes stored in **Cloud Firestore**.
*   **Real-time Updates:** Notes list updates in real-time using Firestore streams.
*   **User Interface:** A clean, minimal UI using the Material 3 theme.
*   **Error Handling:** Provides user-friendly feedback for authentication and data operations using SnackBar.

## ⚙️ Technical Stack

| Component | Technology | Purpose |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.x+ | Cross-platform mobile development |
| **Authentication** | Firebase Auth | User sign-up, login, and session management |
| **Database** | Cloud Firestore | NoSQL database for storing user-specific notes |
| **State Management** | Provider | Simple, scalable, and reactive state management |
| **Data Modeling** | `NoteModel` | Clean mapping of Firestore documents to Dart objects |
| **Architecture** | Service/Provider Pattern | Separation of concerns for clean, testable code |

## 📂 Project Structure

The project follows a clean, modular structure for high readability and maintainability:

```
flutter_notes_app/
├── lib/
│   ├── main.dart                 # App entry point, Firebase init, and main routing
│   ├── firebase_options.dart     # Placeholder for Firebase configuration
│   ├── src/
│   │   ├── models/
│   │   │   └── note_model.dart   # Data model for a Note
│   │   ├── providers/
│   │   │   ├── auth_provider.dart  # Handles all authentication state and logic
│   │   │   └── notes_provider.dart # Handles all notes data state and logic
│   │   ├── screens/
│   │   │   ├── splash_screen.dart  # Initial loading screen
│   │   │   ├── login_screen.dart   # User login form
│   │   │   ├── signup_screen.dart  # User sign-up form
│   │   │   └── home_screen.dart    # Main screen with user info and notes list
│   │   └── services/
│   │       ├── auth_service.dart   # Wrapper for Firebase Auth API calls
│   │       └── firestore_service.dart # Wrapper for Cloud Firestore API calls
└── pubspec.yaml                # Project dependencies
```

## 🚀 Getting Started

### 1. Connect to Firebase

This project requires a Firebase project to run.

1.  **Create a Firebase Project:** Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
2.  **Enable Services:**
    *   **Authentication:** Go to **Build > Authentication** and enable the **Email/Password** sign-in method.
    *   **Firestore:** Go to **Build > Firestore Database** and create a new database.
3.  **Add Flutter App:** Follow the instructions in the Firebase Console to add a Flutter app to your project.
4.  **Install Firebase CLI:** Ensure you have the Firebase CLI installed and configured.
5.  **Generate `firebase_options.dart`:** Run the following command in your project root:

    ```bash
    flutterfire configure
    ```

    This command will generate the `lib/firebase_options.dart` file with your project's configuration. **(Note: The provided file is a placeholder and MUST be replaced by the generated file.)**

### 2. Run the Application

1.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```
2.  **Run the App:**
    ```bash
    flutter run
    ```

## 🎬 Demo Script

This script can be used for a short video demonstration of the app's core functionality.

| Step | Action | Narration |
| :--- | :--- | :--- |
| **1. Splash Screen** | App starts, showing `SplashScreen`. | "The app begins with a splash screen, ensuring Firebase is initialized before proceeding." |
| **2. Sign Up** | Navigate to Sign Up, enter new email/password, and tap 'Sign Up'. | "We'll start by creating a new account using the Email/Password method, complete with client-side form validation." |
| **3. Login** | App automatically logs in and navigates to `HomeScreen`. | "Upon successful sign-up, the user is immediately logged in and taken to the Home Screen." |
| **4. Home Screen** | Point to the user email display. | "The Home Screen displays the logged-in user's email, confirming the successful authentication." |
| **5. Add Note** | Type a note in the input field and tap the 'Add' button. | "Adding a note is simple. The note is instantly saved to Cloud Firestore and appears in the list, demonstrating real-time data fetching." |
| **6. Delete Note** | Tap the delete icon on the note and confirm. | "Users can manage their notes, including a confirmation step for deletion, which also updates the list in real-time." |
| **7. Logout** | Tap the 'Logout' icon and confirm. | "Finally, logging out clears the session and returns the user to the login screen, ready for the next user." |
| **8. State Persistence** | (Optional) Close and reopen the app after login. | "The app uses Firebase's built-in session management, so the user remains logged in even after closing and reopening the app." |
