import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Signs the user into Firebase with their Google account.
///
/// The Pig World API must exchange the resulting Firebase ID token for its own
/// session before this can be used as an application login.
class GoogleSignInService {
  GoogleSignInService({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;
  static final Future<void> _initialization = GoogleSignIn.instance
      .initialize();

  Future<String> signIn() async {
    // Firebase is only needed for the optional Google login flow. Initializing
    // it here keeps an unavailable platform/configuration from blocking app
    // startup before the first screen can render.
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    await _initialization;
    final account = await GoogleSignIn.instance.authenticate();
    final authentication = account.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: authentication.idToken,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final idToken = await userCredential.user?.getIdToken();
    if (idToken == null) {
      throw StateError('Google did not return an authentication token.');
    }
    return idToken;
  }
}
