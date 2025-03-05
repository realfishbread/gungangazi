import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '423735826070-9dq9dd52a4t5u66krjlg2nm0cpq8f92o.apps.googleusercontent.com'  // ✅ 웹용 OAuth 클라이언트 ID 입력
        : Platform.isAndroid
            ? '423735826070-iml5j92c26kqd9l998683q91hs1slk94.apps.googleusercontent.com'  // ✅ 안드로이드용 OAuth 클라이언트 ID 입력
            : null,
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