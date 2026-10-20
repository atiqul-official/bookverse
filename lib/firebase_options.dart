import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const _webAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const _authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
  );

  static const isConfigured =
      _apiKey != '' &&
      _projectId != '' &&
      _messagingSenderId != '' &&
      _webAppId != '' &&
      _authDomain != '';

  static FirebaseOptions get web {
    if (!isConfigured) {
      throw StateError('Web Firebase configuration is incomplete.');
    }

    return FirebaseOptions(
      apiKey: _apiKey,
      appId: _webAppId,
      authDomain: _authDomain,
      messagingSenderId: _messagingSenderId,
      projectId: _projectId,
      storageBucket: _storageBucket.isEmpty ? null : _storageBucket,
    );
  }
}
