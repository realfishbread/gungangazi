import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gungangazi/screen/userHealth/walking_page.dart';
import 'package:provider/provider.dart';

import '../../core_services/dio_service.dart';
import '../../core_services/token_service.dart';
import '../../repositories/status/character_repository.dart';
import '../../widget/is_web.dart';
import '../character/character_status.dart';
import '../character/popup_handler.dart';
import '../chat_page.dart';
import '../profile/profile_page.dart';
import '../userHealth/blood_pressure.dart';
import '../userHealth/meal_page.dart';
import '../userHealth/sleep_page.dart';
import '../userHealth/supplement_page.dart';
import '../userHealth/tooth_care_page.dart';
import '../userHealth/water_drink.dart';
import 'web_home_page.dart';

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key});

  @override
  _MobileHomePageState createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TokenService _tokenService = TokenService();
  final DioService _dioService = DioService(token: 'your-auth-token');

  final List<dynamic> _listData = [];
  late final CharacterRepository _characterRepository;

  bool _isLoaded = false; // 서버에서 캐릭터 상태를 다 불러왔는지
  late PopupHandler _popupHandler;
  late CharacterStatus _characterStatus;

  @override
  void initState() {
    super.initState();

    // Provider를 쓴다면 read() 사용(또는 직접 생성하되, 꼭 "한 번"만 만듦)
    _characterStatus = context.read<CharacterStatus>();

    // 1) 서버에서 상태를 먼저 로드
    _loadCharacterStatus();
  }

  Future<void> _loadCharacterStatus() async {
    // 2) 서버에서 데이터 받아오기 (이 시점 이전에는 late 필드에 접근 금지)
    await _characterStatus.loadStatus();

    // 3) 다 받았으므로, 이제 PopupHandler 만들고
    if (_popupHandler == null) {
      _popupHandler = PopupHandler(
          listData: [],
          tokenService: TokenService(),
          dioService: DioService(),
          characterStatus: _characterStatus);
      _popupHandler.initialize(); // setState 바깥에서 한 번만!
    }

    setState(() {
      _isLoaded = true;
    });
  }

  @override
  void dispose() {
    // 지금까진 그냥 super.dispose()만 했을 수 있음
    _popupHandler.dispose(); // <-- 여기서 타이머 등 정리
    super.dispose();
  }

  void _navigateToPage(BuildContext context, String title) {
    final routes = {
      '수면': SleepPage(
          popupHandler: _popupHandler, characterStatus: _characterStatus),
      '수분': WaterDrink(
          popupHandler: _popupHandler, characterStatus: _characterStatus),
      '식단': MealPage(
          popupHandler: _popupHandler, characterStatus: _characterStatus),
      '영양제': SupplementsPage(popupHandler: _popupHandler),
      '혈압': const BloodPressurePage(),
      '치아건강': ToothCarePage(popupHandler: _popupHandler),
      '만보기': WalkingPage(),
    };

    final page = routes[title];
    if (page != null) {
      Navigator.push(
        //push는 기존 화면 남아있고, 이건 안남아있음
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 3) {
      String? username = await _tokenService.getUsername();
      if (username != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                username: username,
                onProfileUpdated: () {
                  // 프로필 업데이트 후 동기화
                  setState(() {});
                },
              ),
            ));
      } else {
        print('아이디를 찾을 수 없습니다.');
      }
    } else if (_selectedIndex == 0 || _selectedIndex == 1) {
      _scaffoldKey.currentState?.openEndDrawer();
    } else if (_selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SupplementsPage(popupHandler: _popupHandler)),
      );
    }
  }

  void logout(BuildContext context) async {
    await _tokenService.deleteToken(); // 토큰 삭제
    print('토큰이 삭제되었습니다.');

    // 로그인 화면으로 이동
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (isWeb(context)) {
      return WebHomePage();
    }
    if (!_isLoaded) {
      // 아직 데이터가 안 왔으면 로딩 표시
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 모바일 모드일 경우 기존 코드 유지
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: SizedBox(
          child: Image.asset(
            'assets/logo.png', // 이미지 경로
            fit: BoxFit.contain,
          ),
        ),
        leadingWidth: 150,
        backgroundColor: const Color(0xFFFFF9C4),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              logout(context); // 로그아웃 메서드 호출
            },
          ),
        ],
      ),
      endDrawer: SizedBox(
        width: 150,
        child: Drawer(
          child: _getDrawerContent(),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: _popupHandler.buildImageAnimationWithTouch(context,
                (newImagePath) {
              setState(() {});
            }),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFFFFF9C4),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.book),
            label: '자기 관리',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.dumbbell),
            label: '운동',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: '마이 페이지',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black45,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()),
          );
        },
        backgroundColor: const Color(0xFFD9D7F1),
        child: const Icon(FontAwesomeIcons.commentMedical),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _getDrawerContent() {
    switch (_selectedIndex) {
      case 0:
        return ListView(
          padding: EdgeInsets.zero,
          children: _buildDrawerItems(
            '자기 관리',
            [
              {'icon': Icons.dark_mode, 'title': '수면'},
              {'icon': Icons.restaurant, 'title': '식단'},
              {'icon': Icons.water_drop_outlined, 'title': '수분'},
              {'icon': FontAwesomeIcons.tooth, 'title': '치아건강'},
              {'icon': FontAwesomeIcons.heartPulse, 'title': '혈압'},
            ],
          ),
        );
      case 1:
        return ListView(
          padding: EdgeInsets.zero,
          children: _buildDrawerItems(
            '운동',
            [
              {'icon': FontAwesomeIcons.dumbbell, 'title': '만보기'},
            ],
          ),
        );
      default:
        return Container();
    }
  }

  List<Widget> _buildDrawerItems(
      String title, List<Map<String, dynamic>> items) {
    return <Widget>[
      ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const Divider(color: Colors.black),
      ...items.map((item) {
        return Column(
          children: [
            ListTile(
              leading: Icon(item['icon'], color: Colors.black),
              title: Text(
                item['title'],
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                _navigateToPage(context, item['title'] as String);
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      }),
    ];
  }
}
