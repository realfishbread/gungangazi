import 'package:mysql1/mysql1.dart'; // MySQL 패키지 사용
import '../dto/user_dto.dart';

class UserDAO {
  final MySqlConnection _connection;

  UserDAO(this._connection);

  // 사용자 데이터베이스에 저장하는 메서드
  Future<void> saveUser(UserDTO user) async {
    try {
      await _connection.query(
        'INSERT INTO users (username, email, id, password, gender) VALUES (?, ?, ?, ?, ?)',
        [user.username, user.email, user.id, user.password, user.gender],
      );
      print('사용자 저장 성공');
    } catch (e) {
      print('사용자 저장 실패: $e');
    }
  }

  // 데이터베이스에서 사용자 정보를 가져오는 메서드
  Future<UserDTO?> getUserById(String userId) async {
    try {
      var result = await _connection.query(
        'SELECT username, email, id, password, gender FROM users WHERE id = ?',
        [userId],
      );

      if (result.isNotEmpty) {
        var row = result.first;
        return UserDTO(
          username: row['username'],
          email: row['email'],
          id: row['id'],
          password: row['password'],
          gender: row['gender'],
        );
      }
      return null; // 사용자가 없을 때 null 반환
    } catch (e) {
      print('사용자 불러오기 실패: $e');
      return null;
    }
  }
}