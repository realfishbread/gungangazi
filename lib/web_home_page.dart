import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'profile2.dart';
import '../services/dio_service.dart';
import '../services/TokenService.dart';
import 'ToothCarePage.dart';
import 'BloodPressure.dart';
import 'PopupHandler.dart';
import 'SupplementsPage.dart';
import 'SleepPage.dart';
import 'WaterDrink.dart';
import 'MealPage.dart';
import 'ChatPage.dart';
import 'loginPge.dart';
import '../dto/profile_dto.dart';
import '../repositories/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({Key? key}) : super(key: key);

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();

  late PopupHandler _popupHandler; // PopupHandler 선언
  final DioService _dioService = DioService(token: 'your-auth-token');
  final TokenService _tokenService = TokenService();

  ProfileDto? _profile;
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();
    _popupHandler = PopupHandler(listData: [], tokenService: _tokenService, dioService: _dioService);
    fetchProfile(); // 프로필 데이터 가져오기
    _popupHandler.initialize();
  }

  Future<void> fetchProfile() async {
    String? token = await _tokenService.getToken();
    DioService dioService = DioService(token: token);
    ProfileRepository profileRepository = ProfileRepository(dioService: dioService, tokenService: _tokenService);

    ProfileDto? profile = await profileRepository.fetchProfile('your-username'); // 서버에서 프로필 가져오기
    setState(() {
      _profile = profile;
      if (_profile?.profile_image != null) {
        _imageData = base64Decode(_profile!.profile_image!);
      }
    });
  }

  void _navigateToProfile(BuildContext context) async {
    String? username = await _tokenService.getUsername();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 높이를 조절하기 위해 필요한 설정
      backgroundColor: Colors.transparent, // 배경 투명
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8, // 초기 높이 비율 (전체 화면의 80%)
          minChildSize: 0.5, // 최소 높이 비율
          maxChildSize: 0.95, // 최대 높이 비율
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              margin: const EdgeInsets.all(16.0), // 스마트폰처럼 모서리에 여백 추가
              decoration: BoxDecoration(
                color: Colors.white, // 모달 배경색
                borderRadius: BorderRadius.circular(30.0), // 전체적으로 둥근 모서리
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // 그림자 색상
                    blurRadius: 10, // 그림자 흐림 정도
                    offset: const Offset(0, 5), // 그림자 위치
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.0), // 내부 내용도 둥글게
                child: Profile2(
                  username: username ?? "기본아이디",
                  onProfileUpdated: () {
                    // 프로필 변경 후 동기화
                    fetchProfile();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCalendar(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,       // 모달 높이 조절 가능
      backgroundColor: Colors.transparent, // 배경 투명
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8, // 초기 높이 비율
          minChildSize: 0.5,     // 최소 높이 비율
          maxChildSize: 0.95,    // 최대 높이 비율
          builder: (context, scrollController) {
            return Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.0),
                child: SupplementsPage(
                  popupHandler: _popupHandler,
                  // ...필요한 인자 그대로...
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0, // 그림자 제거
        centerTitle: true, // 제목(아이콘)을 가운데로 설정
        leading: SizedBox(
          child: Image.asset(
            'assets/logo.png', // 이미지 경로
            fit: BoxFit.contain,
          ),
        ),
        leadingWidth: 150, // leading의 너비를 120으로 설정
        backgroundColor: const Color(0xFFFFF9C4), // 앱바 배경색
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            color: Colors.black, // 아이콘 색상
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WebHomePage()),
              );
            },
          ),
        ],
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
              selectedHoverColor: const Color.fromARGB(255, 230, 207, 235),
              selectedColor: const Color.fromARGB(255, 229, 176, 238),
              selectedTitleTextStyle: const TextStyle(color: Colors.black),
              selectedIconColor: Colors.black,
            ),
            title: Column(
              children: [
                // 프로필 이미지
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 150,
                    maxWidth: 150,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color.fromARGB(255, 240, 240, 240),
                    backgroundImage: _imageData != null
                        ? MemoryImage(_imageData!) // 서버에서 가져온 이미지
                        : AssetImage('assets/place_holder.png') as ImageProvider, // 기본 이미지
                  ),
                ),
                const SizedBox(height: 8), // 이미지와 텍스트 간 간격
                // 사용자 이름
                Text(
                  _profile?.realname ?? '홍길동', // 프로필 이름
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                // 사용자 이메일
                Text(
                  _profile?.email ?? 'user@example.com', // 프로필 이메일
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                const Divider(
                  indent: 8.0,
                  endIndent: 8.0,
                ),
              ],
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
                    icon: const Icon(Icons.nightlight),
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
                        MaterialPageRoute(builder: (context) => ToothCarePage(popupHandler: _popupHandler)),
                      );
                    },
                    icon: const Icon(Icons.medical_services),
                  ),
                  SideMenuItem(
                    title: '혈압',
                    onTap: (index, _) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BloodPressurePage()),
                      );
                    },
                    icon: const Icon(Icons.favorite),
                  ),
                ],
              ),
               SideMenuItem(
                title: '캘린더',
                onTap: (index, _) {
                  // 기존 Navigator.push -> BottomSheet 호출
                  _showCalendar(context);
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
                    onTap: (index, _) {
                      _navigateToProfile(context);
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
          const VerticalDivider(width: 0),
          Expanded(
            child: Center(
              child: _popupHandler.buildImageAnimationWithTouch(context, (selectedImagePath) {
                print('Selected image path: $selectedImagePath');
              }),
            ),
          ),
        ],
      ),
    );
  }
}
