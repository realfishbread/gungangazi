import 'package:dio/dio.dart';
import '../../dto/userHealth/meal_dto.dart';
import '../../services/dio_service.dart';
import '../../services/TokenService.dart';

class MealRepository {
  final DioService dioService;
  final TokenService tokenService;

  MealRepository({required this.dioService, required this.tokenService});

    Future<List<MealDTO>> fetchAllMeals() async {
    try {
      final Dio dio = dioService.getDio();
      String? username = await tokenService.getUsername(); // username 가져오기
      final response = await dio.get(
        '/meals/get',
        queryParameters: {'username': username},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await tokenService.getToken()}',
          },
        ),
      );
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
      String? username = await tokenService.getUsername();  // username 가져오기
      final response = await dio.post(
        '/meals/post',
        data: {
          ...meal.toJson(),  // 기존 meal 데이터
          'username': username,  // username 추가
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await tokenService.getToken()}',
          },
        ),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to add meal');
      }
    } catch (e) {
      throw Exception('Error adding meal: $e');
    }
  }

   
}
