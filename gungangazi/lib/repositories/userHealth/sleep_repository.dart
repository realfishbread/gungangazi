import 'package:dio/dio.dart';
import '../../dto/userHealth/sleep_dto.dart';
import '../../core_services/dio_service.dart';
import '../../core_services/token_service.dart';

class SleepRepository {
  final DioService dioService;
  final TokenService tokenService;

  SleepRepository({required this.dioService, required this.tokenService});

  // 서버에 수면 데이터를 저장하는 메서드 (POST)
  Future<void> saveSleepDataToDatabase(List<SleepDto> sleepData) async {
    try {
      String? token = await tokenService.getToken();
      String? username = await tokenService.getUsername(); // username 추가
      Dio dio = dioService.getDio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.post(
        '/sleep/saveSleepData',
        data: sleepData.map((e) => e.toJson()).toList(), // records 키 제거
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );

      if (response.statusCode == 200) {
        print('수면 데이터가 서버에 성공적으로 저장되었습니다.');
      } else {
        print('서버에 데이터 저장 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('서버로 데이터를 전송하는 중 오류 발생: $e');
    }
  }

  // 서버에서 수면 데이터를 가져오는 메서드 (GET)
  Future<List<SleepDto>> fetchSleepDataFromDatabase() async {
    try {
      String? token = await tokenService.getToken();
      Dio dio = dioService.getDio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.get('/sleep/getSleepData');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data; // JSON 데이터 목록 가져오기
        List<SleepDto> sleepData = data.map((item) {
          return SleepDto(
            date: item['date'] ?? '',
            sleep_time: item['sleep_time'] ?? '',
            wake_up_time: item['wake_up_time'] ?? '',
            username: item['username'] ?? '',
          );
        }).toList();

        print('서버로부터 수면 데이터를 성공적으로 불러왔습니다.');
        return sleepData;
      } else {
        print('서버로부터 데이터 불러오기 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('서버에서 데이터를 불러오는 중 오류 발생: $e');
      return [];
    }
  }
}
