import 'package:dio/dio.dart';

class DioService {
  final String baseUrl = 'https://gungangazi.site';  // 서버 주소
  String? token;  // 서버에서 받아오는 토큰을 저장할 변수

  // 생성자에서 토큰을 받아서 저장
  DioService({this.token});

  Dio getDio() {
    Dio dio = Dio(BaseOptions(
      baseUrl: baseUrl,  // 서버 기본 URL 설정
      connectTimeout: const Duration(seconds: 5),  // 연결 대기 시간 설정
      receiveTimeout: const Duration(seconds: 3),  // 응답 대기 시간 설정
    ));

    // 요청 전에 실행되는 인터셉터: 요청할 때마다 토큰을 헤더에 추가
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (token != null && token!.isNotEmpty) {
          // 토큰이 있으면 Authorization 헤더에 추가
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);  // 요청을 계속 진행
      },
    ));

    return dio;
  }
}