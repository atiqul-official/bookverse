import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb && !DefaultFirebaseOptions.isConfigured) {
    runApp(const FirebaseConfigurationRequiredApp());
    return;
  }

  try {
    await Firebase.initializeApp(
      options: kIsWeb ? DefaultFirebaseOptions.web : null,
    );
    runApp(const BookVerseApp());
  } on FirebaseException catch (error) {
    runApp(FirebaseStartupErrorApp(message: error.message ?? error.code));
  } on StateError catch (error) {
    runApp(FirebaseStartupErrorApp(message: error.message));
  }
}

class FirebaseConfigurationRequiredApp extends StatelessWidget {
  const FirebaseConfigurationRequiredApp({super.key});

  @override
  Widget build(BuildContext context) => const _FirebaseSetupApp(
    title: 'Firebase setup required',
    message:
        'Connect this app to a Firebase project before using login, Firestore, '
        'or the live book library. See the Firebase setup section in README.md.',
  );
}

class FirebaseStartupErrorApp extends StatelessWidget {
  final String message;

  const FirebaseStartupErrorApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) => _FirebaseSetupApp(
    title: 'Could not start Firebase',
    message: message,
  );
}

class _FirebaseSetupApp extends StatelessWidget {
  final String title;
  final String message;

  const _FirebaseSetupApp({required this.title, required this.message});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
    ),
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 56, color: primary),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    ),
  );
}
