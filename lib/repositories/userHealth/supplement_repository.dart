import 'package:dio/dio.dart';
import '../../dto/userHealth/supplement_dto.dart';
import '../../core_services/dio_service.dart';
import '../../core_services/token_service.dart';
import 'package:intl/intl.dart';


class SupplementRepository {
  final DioService dioService;
  final TokenService tokenService;

  SupplementRepository({required this.dioService, required this.tokenService});

  Future<void> saveSupplement(SupplementDto supplementDto) async {
    try {
      // 토큰과 유저 이름을 가져옵니다.
      String? token = await tokenService.getToken();
      String? username = await tokenService.getUsername();
      Dio dio = dioService.getDio();
      print("Sending data: ${supplementDto.toJson()}");

      // 요청 헤더에 Authorization 추가
      dio.options.headers['Authorization'] = 'Bearer $token';

      // 서버에 데이터 전송
      await dio.post(
        '/supplements/save',
        data: {
          ...supplementDto.toJson(),
        },
      );
      print('영양제 복용 데이터 저장 완료');
    } catch (e) {
      print('데이터 저장 실패: $e');
    }
  }

  Future<List<SupplementDto>> fetchSupplements() async {
    try {
      // 토큰을 가져와 요청 헤더에 추가
      String? token = await tokenService.getToken();
      Dio dio = dioService.getDio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      // 서버로부터 데이터 가져오기
      final response = await dio.get('/supplements/all');

      // JSON 데이터를 SupplementDto 객체 리스트로 변환
      List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => SupplementDto.fromJson(json)).toList();
    } catch (e) {
      print('영양제 기록 불러오기 에러: $e');
      return [];
    }
  }

  Future<SupplementDto?> fetchSingleSupplement(String username, DateTime date) async {
  try {
    String? token = await tokenService.getToken();
    final Dio dio = dioService.getDio();
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final response = await dio.get(
      '/supplements/single',
      queryParameters: {
        'username': username,
        'date': formattedDate,
      },
      options: Options(
          headers: {
            'Authorization': 'Bearer $token', // 인증 토큰 추가
          },
        ),
    );
    return response.data != null ? SupplementDto.fromJson(response.data) : null;
  } catch (e) {
    print('Error fetching single supplement data: $e');
    return null;
  }
}

}
