// services/dio_service.dart
import 'package:dio/dio.dart';

class DioService {
  Dio getDio() {
    Dio dio = Dio(BaseOptions(
      baseUrl: 'http://15.164.140.55/api',
      connectTimeout: const Duration(seconds: 5), // 수정: int에서 Duration으로 변경
      receiveTimeout: const Duration(seconds: 3), // 수정: int에서 Duration으로 변경
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer your_token';
        return handler.next(options);
      },
    ));

    return dio;
  }
}
