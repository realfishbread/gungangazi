import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? dotenv.env['GOOGLE_CLIENT_ID_WEB'] // ✅ 웹용 OAuth 클라이언트 ID 입력
        : Platform.isAndroid
            ? dotenv.env['GOOGLE_CLIENT_ID_ANDROID']  // ✅ 안드로이드용 OAuth 클라이언트 ID 입력
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