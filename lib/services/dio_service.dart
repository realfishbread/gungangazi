import 'package:dio/dio.dart';

class DioService {
  final String baseUrl = 'https://gungangazi.site';  // 서버 주소
  String? token;  // 서버에서 받은 토큰을 저장할 변수

  // 생성자에서 토큰을 받아서 저장 (토큰이 없다면 null)
  DioService({this.token});

  // getDio() 함수는 Dio 객체를 반환
  Dio getDio() {
    Dio dio = Dio(BaseOptions(
      baseUrl: baseUrl,  // 서버 주소 설정
      connectTimeout: const Duration(seconds: 5),  // 연결 대기 시간 설정
      receiveTimeout: const Duration(seconds: 3),  // 응답 대기 시간 설정
    ));

    // 요청할 때마다 토큰을 헤더에 추가하는 부분
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 만약에 토큰이 있으면 헤더에 추가!
        if (token != null && token!.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print("Request: ${options.uri}");  // 요청 URL 출력
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("Response: ${response.statusCode} - ${response.data}");
        return handler.next(response);
      },
      onError: (DioError e, handler) {
        print("Error: ${e.response?.statusCode} - ${e.response?.data}");
        return handler.next(e);
      },
    ));

    return dio;  // Dio 객체 반환 (이걸로 API 요청을 할 수 있음)
  }
}