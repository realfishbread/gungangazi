import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthConnectService {
  final Health health = Health(); // ✅ Health 인스턴스 생성

  /// ✅ Health Connect 권한 요청
  Future<void> requestPermissions() async {
    // 퍼미션 요청
    Map<Permission, PermissionStatus> statuses = await [
      Permission.activityRecognition,
      Permission.sensors,
      Permission.location,
    ].request();

    if (statuses[Permission.activityRecognition]!.isGranted) {
      print("✅ 걸음 수 권한 허용됨!");
    } else {
      print("🚨 걸음 수 권한 거부됨!");
    }
  }

  /// ✅ 걸음 수 데이터 가져오기
  Future<int> fetchSteps() async {
    bool requested = await health.requestAuthorization([HealthDataType.STEPS]);

    if (!requested) {
      print("🚨 Health Connect 권한 요청 실패!");
      return 0;
    }

    DateTime now = DateTime.now();
    DateTime start = now.subtract(Duration(days: 1));

    List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
      startTime: start,
      endTime: now,
      types: [HealthDataType.STEPS],
    );

    if (healthData.isNotEmpty) {
      int steps = healthData.first.value as int;
      print("✅ Health Connect 걸음 수: $steps");
      return steps;
    } else {
      print("🚨 걸음 수 데이터 없음!");
      return 0;
    }
  }
}
