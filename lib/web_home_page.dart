import 'package:gungangazi/splash/SplashPage.dart';
import 'ToothCarePage.dart';
import 'BloodPressure.dart';
import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'PopupHandler.dart';
import 'profile2.dart';
import 'SupplementsPage.dart';
import 'SleepPage.dart';
import 'WaterDrink.dart';
import 'MealPage.dart';
import 'ChatPage.dart';
import 'loginPge.dart';
import '../services/TokenService.dart';
import '../services/dio_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WebHomePage extends StatelessWidget {
  const WebHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '건강아지',
      theme: ThemeData(
        primaryColor: const Color(0xFFFFF9C4), // 기본 색상 변경
        scaffoldBackgroundColor: Colors.white, // 배경 색상 흰색으로 변경
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFF9C4), // 앱바 색상 변경
          titleTextStyle: TextStyle( // 앱바 텍스트 스타일
            color: Colors.black, // 앱바 텍스트 색상 검은색으로 변경
            fontSize: 20,
          ),
          iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상 검은색으로 설정
        ),
        useMaterial3: false,
      ),
      home: const MyHomePage(title: '건강아지'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();

  List<dynamic> _listData = [];
  late PopupHandler _popupHandler; // PopupHandler 선언
  final DioService _dioService = DioService(token: 'your-auth-token');
  final TokenService _tokenService = TokenService();

  @override
  void initState() {
    super.initState();
    _popupHandler = PopupHandler(listData: _listData, tokenService: _tokenService, dioService: _dioService);
  }

  @override
  void dispose() {
    _popupHandler.dispose(); // PopupHandler 리소스 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0, // 그림자 제거
        centerTitle: true, // 제목(아이콘)을 가운데로 설정
        title: const Icon(Icons.local_hospital_outlined, color: Colors.black), // 가운데에 아이콘 추가
        backgroundColor: const Color(0xFFFFF9C4), // 앱바 배경색
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            controller: sideMenu,
            style: SideMenuStyle(
              displayMode: SideMenuDisplayMode.auto,
              showHamburger: true,
              hoverColor: Colors.purple[100],
              selectedHoverColor: Colors.purple[100],
              selectedColor: const Color.fromARGB(255, 229, 176, 238),
              selectedTitleTextStyle: const TextStyle(color: Colors.black),
              selectedIconColor: Colors.black,
            ),
            footer: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  child: Text(
                    '건강아지',
                    style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                  ),
                ),
              ),
            ),
            items: [
              SideMenuExpansionItem(
                title: "내과",
                icon: const Icon(Icons.medical_services_outlined),
                children: [
                  SideMenuItem(
                    title: '수면',
                    onTap: (index, _) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SleepPage(popupHandler: _popupHandler)),
                      );
                    },
                    icon: const Icon(Icons.bedtime),
                  ),
                  SideMenuItem(
                    title: '식단',
                    onTap: (index, _) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MealPage(popupHandler: _popupHandler)),
                      );
                    },
                    icon: const Icon(Icons.restaurant),
                  ),
                  SideMenuItem(
                    title: '수분',
                    onTap: (index, _) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WaterDrink(popupHandler: _popupHandler)),
                      );
                    },
                    icon: const Icon(Icons.water_drop),
                  ),
                ],
              ),
              SideMenuExpansionItem(
                title: "외과",
                icon: const Icon(Icons.local_hospital_outlined),
                children: [
                  SideMenuItem(
                    title: '치아 건강',
                    onTap: (index, _) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  ToothCarePage(popupHandler: _popupHandler)),
                      );

                    },
                    icon: const Icon(Icons.medical_services),
                  ),
                  SideMenuItem(
                    title: '혈압',
                    onTap: (index, _) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  BloodPressurePage()),
                      );
                    },
                    icon: const Icon(Icons.favorite),
                  ),
                ],
              ),
              SideMenuItem(
                title: '캘린더',
                onTap: (index, _) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SupplementsPage(popupHandler: _popupHandler)),
                  );
                },
                icon: const Icon(Icons.calendar_today),
              ),

              SideMenuItem(
                title: '채팅',
                onTap: (index, _) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatPage()),
                  );
                },
                icon: const Icon(FontAwesomeIcons.commentMedical),
              ),
              SideMenuItem(
                builder: (context, displayMode) {
                  return const Divider(
                    endIndent: 8,
                    indent: 8,
                  );
                },
              ),
              SideMenuItem(
                title: '프로필',
                onTap: (index, _) async { // async 추가
                  String? username = await _tokenService.getUsername(); // 비동기 처리로 username 가져오기
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Profile2(
                        username: username ?? "기본아이디", // username이 null이면 기본값 사용
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.person),
              ),
              SideMenuItem(
                builder: (context, displayMode) {
                  return const Divider(
                    endIndent: 8,
                    indent: 8,
                  );
                },
              ),
              SideMenuItem(
                title: '로그아웃',
                onTap: (index, _) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                icon: const Icon(Icons.login),
              ),
            ],
          ),
          const VerticalDivider(
            width: 0,
          ),
          Expanded(
            child: Center(
              // PopupHandler의 buildImageAnimationWithTouch를 메인 화면에 표시
              child: _popupHandler.buildImageAnimationWithTouch(context, (selectedImagePath) {
                // 이미지가 선택되었을 때 처리할 내용
                print('Selected image path: $selectedImagePath');
              }),
            ),
          ),
        ],
      ),
    );
  }
}
