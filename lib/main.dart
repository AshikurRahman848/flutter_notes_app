import 'dart:async';
import 'dart:ui'; // for PlatformDispatcher
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/notes_provider.dart';
import 'src/screens/splash_screen.dart';
import 'src/screens/login_screen.dart';
import 'src/screens/signup_screen.dart';
import 'src/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Surface all Flutter framework errors to console
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };

  // Catch uncaught asynchronous errors (timers, futures, isolates)
  PlatformDispatcher.instance.onError = (error, stack) {
    // Use debugPrint so analyzer doesn't warn about `print` in production code.
    debugPrint('Uncaught platform error: $error\n$stack');
    return true; // handled
  };

  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stack) {
    // Use debugPrint to avoid analyzer avoid_print lint while still logging during development.
    debugPrint('Uncaught zone error: $error\n$stack');
  });
}

/// Main application widget.
/// Initializes Firebase (with loading & error states), sets up Providers, and handles routing.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Future<FirebaseApp> _firebaseInit;
  bool _isLoginScreen = true;

  @override
  void initState() {
    super.initState();
    _firebaseInit = _initFirebase();
  }

  Future<FirebaseApp> _initFirebase() async {
    try {
      return await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e, st) {
      // ignore: avoid_print
      print('Firebase init failed: $e\n$st');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FirebaseApp>(
      future: _firebaseInit,
      builder: (context, snapshot) {
        // Loading: show your splash while Firebase initializes
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
          );
        }

        // Error: show a readable error so you don't just "lose connection"
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Initialization error',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text('${snapshot.error}'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _firebaseInit = _initFirebase(); // retry
                        }),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Ready: build the real app with Providers
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => NotesProvider()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Notes App',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            ),
            home: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (auth.isLoggedIn) {
                  return HomeScreen(
                    onLogout: () => setState(() => _isLoginScreen = true),
                  );
                }
                return _isLoginScreen
                    ? LoginScreen(onSignUpTap: () => setState(() => _isLoginScreen = false))
                    : SignUpScreen(onLoginTap: () => setState(() => _isLoginScreen = true));
              },
            ),
          ),
        );
      },
    );
  }
}
