import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  // GoogleSignIn 인스턴스 생성
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '423735826070-9dq9dd52a4t5u66krjlg2nm0cpq8f92o.apps.googleusercontent.com'  // 웹용 OAuth 클라이언트 ID
        : Platform.isAndroid
            ? '423735826070-iml5j92c26kqd9l998683q91hs1slk94.apps.googleusercontent.com'  // 안드로이드용 OAuth 클라이언트 ID
            : null,
    scopes: <String>[
      'openid',
      'email',
      'profile',
      'https://www.googleapis.com/auth/user.gender.read',
    ],
  );

  /// ✅ Auth Code를 반환하도록 수정
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        print('❌ User canceled login');
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final String? authCode = account.serverAuthCode;

      if (authCode == null) {
        print('❌ Server Auth Code is null.');
        return null;
      }

      print('✅ Auth Code from Google: $authCode');
      return authCode;  // 🔥 이제 Auth Code를 반환하도록 수정!
    } catch (e) {
      print('❌ Google Sign-In Error: $e');
      return null;
    }
  }
}
