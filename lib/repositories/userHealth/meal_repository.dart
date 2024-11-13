import 'package:dio/dio.dart';
import '../../dto/userHealth/meal_dto.dart';
import '../../services/dio_service.dart';
import '../../services/TokenService.dart';

class MealRepository {
  final DioService dioService;
  final TokenService tokenService;

  MealRepository({required this.dioService, required this.tokenService});

  // 날짜별 식사 기록 가져오기
  Future<List<MealDTO>> fetchMealsByDate(String date) async {
    try {
      final Dio dio = dioService.getDio();
      String? username = await tokenService.getUsername();  // username 가져오기
      final response = await dio.get('/meals/get', queryParameters: {'date': date, 'username': username});
      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((meal) => MealDTO.fromJson(meal)).toList();
      } else {
        throw Exception('Failed to load meals');
      }
    } catch (e) {
      throw Exception('Error fetching meals: $e');
    }
  }

  // 새로운 식사 추가
  Future<void> addMeal(MealDTO meal) async {
    try {
      final Dio dio = dioService.getDio();
      final response = await dio.post(
        '/meals/post',
        data: meal.toJson(),  // meal에 username 포함
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to add meal');
      }
    } catch (e) {
      throw Exception('Error adding meal: $e');
    }
  }
}
