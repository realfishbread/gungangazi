import 'package:dio/dio.dart';
import '../../dto/userHealth/blood_pressure_dto.dart';
import '../../core_services/dio_service.dart';
import '../../core_services/token_service.dart';

class BloodPressureRepository {
  final DioService dioService;
  final TokenService tokenService;

  BloodPressureRepository({required this.dioService, required this.tokenService});

  // 서버에 혈압 데이터를 저장하는 메서드 (POST)
  Future<void> saveBloodPressureDataToDatabase(BloodPressureDTO data) async {
    try {
      String? token = await tokenService.getToken();
      String? username = await tokenService.getUsername();
      Dio dio = dioService.getDio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      // 데이터에 username 추가
      final bloodPressureData = {
        ...data.toJson(),
        'username': username,
      };

      final response = await dio.post(
        '/bloodPressure/saveBloodPressureData',
        data: bloodPressureData,
        queryParameters: {'username': username},
      );

      if (response.statusCode == 200) {
        print('혈압 데이터가 서버에 성공적으로 저장되었습니다.');
      } else {
        print('서버에 데이터 저장 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('서버로 데이터를 전송하는 중 오류 발생: $e');
    }
  }

  // 서버에서 혈압 데이터를 가져오는 메서드 (GET)
  Future<List<BloodPressureDTO>> fetchBloodPressureDataFromDatabase() async {
    try {
      String? token = await tokenService.getToken();
      String? username = await tokenService.getUsername();
      Dio dio = dioService.getDio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      final response = await dio.get(
        '/bloodPressure/getBloodPressureData',
        queryParameters: {'identifier': username},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data; // JSON 데이터 목록 가져오기
        List<BloodPressureDTO> bloodPressureData = data.map((item) {
          return BloodPressureDTO.fromJson(item);
        }).toList();

        print('서버로부터 혈압 데이터를 성공적으로 불러왔습니다.');
        return bloodPressureData;
      } else {
        print('서버로부터 데이터 불러오기 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('서버에서 데이터를 불러오는 중 오류 발생: $e');
      return [];
    }
  }

   // 서버에서 혈압 데이터를 삭제하는 메서드
  Future<void> deleteBloodPressureDataFromDatabase(BloodPressureDTO record) async {
    try {
      final Dio dio = await dioService.getDio(); // Dio 인스턴스 가져오기
      final String? token = await tokenService.getToken(); // 토큰 가져오기

      if (token == null) {
        throw Exception("토큰을 찾을 수 없습니다.");
      }

      // DELETE 요청 전송
      final response = await dio.delete(
        '/bloodPressure/deleteBloodPressureData', 
         queryParameters: {
        'id': record.id, // 쿼리 파라미터로 id 전달
      },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // 인증 토큰 추가
          },
        ),
      );

      if (response.statusCode == 200) {
        print("데이터 삭제 성공: ${record.id}");
      } else {
        throw Exception("데이터 삭제 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("데이터 삭제 중 오류 발생: $e");
      throw Exception("서버에서 데이터를 삭제할 수 없습니다.");
    }
  }
}



