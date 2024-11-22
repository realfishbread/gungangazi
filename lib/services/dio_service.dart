import 'package:dio/dio.dart';

class DioService {
  final String baseUrl = 'https://gungangazi.site';
  String? token;

  // 생성자에서 토큰을 받도록 변경합니다.
  DioService({this.token});

  Dio getDio() {
    Dio dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
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
      onError: (DioError e, handler) {
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
}
