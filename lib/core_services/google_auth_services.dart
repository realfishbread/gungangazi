import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '423735826070-9dq9dd52a4t5u66krjlg2nm0cpq8f92o.apps.googleusercontent.com',
    scopes: <String>[
      'openid',
      'email',
      'profile',
      'https://www.googleapis.com/auth/user.gender.read',
    ],
  );

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      return googleAuth.accessToken;
    } catch (e) {
      print('Google 로그인 오류: $e');
      return null;
    }
  }
}
