import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:example4/main.dart'; // 'your_project_name'을 실제 프로젝트 이름으로 변경

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // 앱을 빌드하고 시작
    await tester.pumpWidget(MyApp());

    // 초기 카운터 값 확인
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // 버튼 클릭
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // 카운터 값이 1로 증가했는지 확인
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
