import 'package:dio/dio.dart';
import '../../dto/userHealth/SupplementDto.dart';
import '../../services/dio_service.dart';
import '../../services/TokenService.dart';

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

      // 요청 헤더에 Authorization 추가
      dio.options.headers['Authorization'] = 'Bearer $token';

      // 서버에 데이터 전송
      await dio.post(
        '/supplements/save',
        data: {
          ...supplementDto.toJson(),
          'username': username, // username을 추가하는 경우
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
}
