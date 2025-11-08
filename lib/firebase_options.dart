// File generated-like: Firebase configuration options used by Firebase.initializeApp.
// These values are sourced from android/app/google-services.json and ios/Runner/GoogleService-Info.plist.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have no web configuration. Configure web separately.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  // Android Firebase configuration from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCGqe6wcDkOgOntm1w9fNSkUcr47lHyav0',
    appId: '1:812441097745:android:21c960a29de01b42fe83b0',
    messagingSenderId: '812441097745',
    projectId: 'flutter-note-apps-7ba02',
    storageBucket: 'flutter-note-apps-7ba02.firebasestorage.app',
  );

  // iOS Firebase configuration from GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC9I4P0o5EkU4uQtLUBuEYfKEDNEz2skHs',
    appId: '1:812441097745:ios:b291cfeaba517d6efe83b0',
    messagingSenderId: '812441097745',
    projectId: 'flutter-note-apps-7ba02',
    storageBucket: 'flutter-note-apps-7ba02.firebasestorage.app',
    iosBundleId: 'com.flutternoteapps',
  );
}
