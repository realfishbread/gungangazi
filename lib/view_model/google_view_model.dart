import 'package:flutter/material.dart';
import '../repositories/auth/auth_repository.dart';
import '../widget/alert.dart';

class GoogleViewModel {
  final AuthRepository _authRepository;

  GoogleViewModel(this._authRepository);

  

Future<void> _handleGoogleLogin(BuildContext context, Function(bool) onLoading) async {
    onLoading(true); // ✅ 로딩 상태 시작
    try {
      // 레포지토리 통해 구글 로그인
      final responseBody = await _authRepository.googleLogin();
      if (responseBody != null) {
        // 로그인 성공 시
        
        Navigator.pushReplacementNamed(context, '/homeApp', arguments: {
          'email': responseBody['email'],
          'realname': responseBody['realname'],
          'existingUser': responseBody['existingUser'],
          'gender': responseBody['gender'],
          'username': responseBody['username'],
          'token': responseBody['token'],
        });

        showInfoDialog(context,
          responseBody['existingUser']
              ? '기존 회원으로 로그인되었습니다.'
              : '신규 회원으로 가입되었습니다.',
        );
      } else {
        showErrorDialog(context,'Google 로그인 실패');
      }
    } catch (e) {
      print('Google 로그인 중 오류 발생: $e');
      showErrorDialog(context,'Google 로그인 중 오류가 발생했습니다.');
    } finally {
      onLoading(false); // ✅ 로딩 상태 해제
    }
  }
}