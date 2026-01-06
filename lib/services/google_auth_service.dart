import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    // 1. Select Google account
    final GoogleSignInAccount? googleUser =
        await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Login cancelled');
    }

    // 2. Get auth details
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // 3. Create Firebase credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 4. Sign in to Firebase
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
