import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Signs the user into Firebase with their Google account.
///
/// The Pig World API must exchange the resulting Firebase ID token for its own
/// session before this can be used as an application login.
class GoogleSignInService {
  GoogleSignInService({FirebaseAuth? firebaseAuth})
    : _providedFirebaseAuth = firebaseAuth;

  final FirebaseAuth? _providedFirebaseAuth;

  static const String _defaultWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  static String get webClientId => _defaultWebClientId;

  static void validateConfiguration(String clientId) {
    final normalized = clientId.trim();
    if (normalized.isEmpty || !normalized.contains('googleusercontent.com')) {
      throw const GoogleSignInConfigurationException(
        'Google sign-in is not configured yet. Add the Firebase web client ID as GOOGLE_WEB_CLIENT_ID and rebuild the app.',
      );
    }
  }

  Future<String> signIn() async {
    // Firebase is only needed for the optional Google login flow. Initializing
    // it here keeps an unavailable platform/configuration from blocking app
    // startup before the first screen can render.
    try {
      validateConfiguration(webClientId);
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      await GoogleSignIn.instance.initialize(serverClientId: webClientId);
      final account = await GoogleSignIn.instance.authenticate();
      final authentication = account.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
      );
      final firebaseAuth = _providedFirebaseAuth ?? FirebaseAuth.instance;
      final userCredential = await firebaseAuth.signInWithCredential(
        credential,
      );
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw StateError('Google did not return an authentication token.');
      }
      return idToken;
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.clientConfigurationError ||
          error.code == GoogleSignInExceptionCode.providerConfigurationError) {
        throw const GoogleSignInConfigurationException(
          'Google sign-in is not configured for this app yet. Add the Firebase web client ID and rebuild the app.',
        );
      }
      rethrow;
    }
  }
}

class GoogleSignInConfigurationException implements Exception {
  const GoogleSignInConfigurationException([this.message = '']);

  final String message;

  @override
  String toString() =>
      message.isEmpty ? 'GoogleSignInConfigurationException' : message;
}
