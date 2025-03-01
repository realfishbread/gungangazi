import 'package:flutter/material.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gungangazi/repositories/status/character_repository.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../profile/profile_page.dart';
import '../../core_services/dio_service.dart';
import '../../core_services/token_service.dart';
import '../userHealth/tooth_care_page.dart';
import '../userHealth/blood_pressure.dart';
import '../character/popup_handler.dart';
import '../userHealth/supplement_page.dart';
import '../userHealth/sleep_page.dart';
import '../userHealth/water_drink.dart';
import '../userHealth/meal_page.dart';
import '../chat_page.dart';
import '../../dto/auth/profile_dto.dart';
import '../../repositories/auth/profile_repository.dart';
import '../userHealth/walking_page.dart';
import 'home_page.dart';
import '../character/character_status.dart';
import 'package:provider/provider.dart';

class WebHomePage extends StatefulWidget {
  const WebHomePage({Key? key}) : super(key: key);

  @override
  State<WebHomePage> createState() => _WebHomePageState();
}

class _WebHomePageState extends State<WebHomePage> {
  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();

  
  final DioService _dioService = DioService(token: 'your-auth-token');
  final TokenService _tokenService = TokenService();
  late final CharacterRepository _characterRepository;


  ProfileDto? _profile;
  Uint8List? _imageData;

  bool _isLoaded = false; // 서버에서 캐릭터 상태를 다 불러왔는지
  late PopupHandler _popupHandler;
  late CharacterStatus _characterStatus;
  

  @override
  void initState() {
    super.initState();


 Future.microtask(() {
    // Provider를 쓴다면 read() 사용(또는 직접 생성하되, 꼭 "한 번"만 만듦)
    _characterStatus = context.read<CharacterStatus>(); 
    fetchProfile();

    // 1) 서버에서 상태를 먼저 로드
    _loadCharacterStatus();
    });
  }

  @override
  void dispose() {
    // 지금까진 그냥 super.dispose()만 했을 수 있음
    _popupHandler.dispose(); // <-- 여기서 타이머 등 정리
    super.dispose();
  }

Future<void> _loadCharacterStatus() async {
    // 2) 서버에서 데이터 받아오기 (이 시점 이전에는 late 필드에 접근 금지)
    await _characterStatus.loadStatus();

    // 3) 다 받았으므로, 이제 PopupHandler 만들고
    setState(() {
      _popupHandler = PopupHandler(
        listData: [],
        tokenService: TokenService(),
        dioService: DioService(),
        characterStatus: CharacterStatus()
      );
      _isLoaded = true; // 로드 끝
      _popupHandler.setBodyPartStatus();       // 🔥 자동으로 상태 반영
      _popupHandler.startImageAnimation();     // 🔥 자동 애니메이션 시작
    });
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
    
    void logout(BuildContext context) async {
      await _tokenService.deleteToken(); // 토큰 삭제
      setState(() {
        _profile = null;
        _imageData = null;
      });
      Navigator.pushReplacementNamed(context, '/login');
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
                child: ProfilePage(
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

    if (!_isLoaded) {
      // 아직 데이터가 안 왔으면 로딩 표시
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 0, // 그림자 제거
        centerTitle: true, // 제목(아이콘)을 가운데로 설정
        leading: SizedBox(
          child: Image.asset(
            'assets/logo.png',
            width: MediaQuery.of(context).size.width * 0.5, // 화면 너비의 50%
            height: MediaQuery.of(context).size.width * 0.5, // 화면 너비의 50%
            fit: BoxFit.contain, // 비율을 유지하면서 꽉 채우기
          )
        ),
        leadingWidth: 140, // leading의 너비를 120으로 설정
        backgroundColor: const Color(0xFFFFF9C4), // 앱바 배경색
        actions: [
          Tooltip(
            message: '홈페이지',
            child: IconButton(
              icon: const Icon(Icons.home),
              color: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
            ),
          ),
        ],

      ),

      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            controller: sideMenu,
            style: SideMenuStyle(
              backgroundColor: const Color.fromARGB(255, 247, 247, 247), // 드로어 배경색 추가
              displayMode: SideMenuDisplayMode.auto,
              showHamburger: true,
              hoverColor: const Color.fromARGB(255, 242, 217, 247),
              selectedHoverColor: const Color.fromARGB(255, 217, 145, 235),
              selectedColor: const Color.fromARGB(255, 225, 171, 235),
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
                    '건강하지',
                    style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                  ),
                ),
              ),
            ),
            items: [
              SideMenuExpansionItem(
                title: " 자기관리",
                icon: const Icon(FontAwesomeIcons.book),
                children: [
                  SideMenuItem(
                    title: '수면',
                    onTap: (index, _) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SleepPage(popupHandler: _popupHandler, characterStatus: _characterStatus),),
                      );
                    },
                    icon: const Icon(Icons.nightlight),
                  ),

                  SideMenuItem(
                    title: '식단',
                    onTap: (index, _) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MealPage(popupHandler: _popupHandler, characterStatus: _characterStatus)),
                      );
                    },
                    icon: const Icon(Icons.restaurant),
                  ),
                  SideMenuItem(
                    title: '수분',
                    onTap: (index, _) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WaterDrink(popupHandler: _popupHandler, characterStatus: _characterStatus)),
                      );
                    },
                    icon: const Icon(Icons.water_drop),
                  ),
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
              SideMenuExpansionItem(
                title: " 운동",
                icon: const Icon(FontAwesomeIcons.dumbbell),
                children: [
                   SideMenuItem(
                    title: '만보기',
                    onTap: (index, _) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WalkingPage()),
                      );
                    },
                    icon: const Icon(Icons.directions_walk),
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
              onTap: (index, _) async {
                logout(context);
              },
              icon: const Icon(Icons.logout),
            ),
            ],
            ),
            Expanded(
              child: Center(
                child: _popupHandler.buildImageAnimationWithTouch(context, (selectedImagePath) {
                  print('Selected image path: $selectedImagePath');
                }),
              ),
            ),
        ]
      )
    );
  }
}