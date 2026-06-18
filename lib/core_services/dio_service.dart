import 'package:dio/dio.dart';

import 'token_service.dart';

class DioService {
  static final String baseUrl = 'https://gunganghazi.site';
  String? token;
  final TokenService tokenService = TokenService(); // TokenService 인스턴스 생성

  // 생성자에서 토큰을 받도록 변경합니다.
  DioService({this.token});

  Dio getDio() {
    Dio dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (token != null && token!.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print("Request: ${options.uri}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("Response: ${response.statusCode} - ${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print("Error: ${e.response?.statusCode} - ${e.response?.data}");
        return handler.next(e);
      },
    ));

    return dio;
  }

  // DELETE 메서드 수정
  Future<Response> delete(String path, {Map<String, dynamic>? headers}) async {
    try {
      final dio = getDio(); // getDio() 메서드를 호출해 Dio 인스턴스 가져오기
      return await dio.delete(
        path,
        options: Options(headers: headers),
      );
    } catch (e) {
      throw Exception('DELETE 요청 실패: $e');
    }
  }

  Future<String?> getGender() async {
    try {
      // 토큰 가져오기
      final token = await tokenService.getToken();
      if (token == null) {
        print("Token is null");
        return null;
      }

      // 서버 API 호출
      final response = await DioService().getDio().get(
            '/profile', // 예: 서버에서 사용자 프로필 반환
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
            ),
          );

      // API 응답 처리
      if (response.statusCode == 200) {
        final data = response.data;
        print("Fetched gender: ${data['gender']}");
        return data['gender']; // 서버에서 반환된 성별 값
      } else {
        print("Failed to fetch gender: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching gender: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      // 토큰 가져오기
      final token = await tokenService.getToken();
      if (token == null) {
        print("Token is null");
        return null;
      }

      // 서버 API 호출
      final response = await getDio().get(
        '/profile', // 예: 서버에서 사용자 프로필 반환
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // API 응답 처리
      if (response.statusCode == 200) {
        final data = response.data;
        print("Fetched user info: $data");
        return data; // 서버에서 반환된 프로필 데이터 전체 반환
      } else {
        print("Failed to fetch user info: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error fetching user info: $e");
      return null;
    }
  }
}
