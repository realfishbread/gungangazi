import 'package:flutter/material.dart';

import '../../core_services/token_service.dart';
import '../../dto/auth/user_dto.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../dto/auth/login_dto.dart';
import '../../core_services/dio_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final TokenService _tokenService;
  final DioService _dioService;

  AuthViewModel({
    required AuthRepository authRepository,
    required TokenService tokenService,
    required DioService dioService
  })  : _authRepository = authRepository,
        _tokenService = tokenService,
         _dioService = dioService;

  UserDTO? _user;
  bool _isLoading = false;
  String? _error;

  UserDTO? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 로그인 처리
  Future<void> login(String username, String password) async {
    _setLoading(true);
    try {
      // 1. 로그인 요청 (token 반환)
      final loginResult = await _authRepository.login(
        LoginRequestDto(username: username, password: password),
      );

      if (loginResult != null) {
        // 2. 토큰 저장
        await _tokenService.saveToken(loginResult.token);

        // ✅ 3. 토큰 기반 사용자 정보 요청
       final userInfo = await _dioService.getUserInfo();
        if (userInfo != null) {
          _user = UserDTO.fromJson(userInfo); // ✅ 여기서 진짜 user 세팅
        }

        _error = null;
        notifyListeners();
      } else {
        _error = '아이디 또는 비밀번호가 잘못되었습니다.';
      }
    } catch (e) {
      _error = '로그인 도중 오류 발생: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
