import 'BloodPressure.dart';
import 'ToothCarePage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'profile2.dart';
import 'package:flutter/material.dart';
import 'PopupHandler.dart';
import 'SupplementsPage.dart';
import 'SleepPage.dart';
import 'WaterDrink.dart';
import 'MealPage.dart';
import 'ChatPage.dart';
import '../services/TokenService.dart';
import '../services/dio_service.dart';
import 'package:flutter/foundation.dart';
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
  final List<dynamic> _listData = [];
  late PopupHandler _popupHandler;
  final DioService _dioService = DioService(token: 'your-auth-token');

  

  @override
  void initState() {
    super.initState();
    _popupHandler = PopupHandler(listData: _listData, tokenService: _tokenService, dioService: _dioService);
  }

  @override
  void dispose() {
    _popupHandler.dispose();
    super.dispose();
  }


  void _navigateToPage(BuildContext context, String title) {
    final routes = {
      '수면': SleepPage(popupHandler: _popupHandler),
      '수분': WaterDrink(popupHandler: _popupHandler),
      '식단': MealPage(popupHandler: _popupHandler),
      '영양제': const SupplementsPage(),
      '혈압': const BloodPressurePage(),
      '치아건강': ToothCarePage(popupHandler: _popupHandler)
    };

    final page = routes[title];
    if (page != null) {
      Navigator.push(
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
            builder: (context) => Profile2(username: username),
          ),
        );
      } else {
        print('아이디를 찾을 수 없습니다.');
      }
    } else if (_selectedIndex == 0 || _selectedIndex == 1) {
      _scaffoldKey.currentState?.openEndDrawer();
    } else if (_selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SupplementsPage()),
      );
    }
  }

 

 @override
Widget build(BuildContext context) {
  // 화면 너비 가져오기
  double screenWidth = MediaQuery.of(context).size.width;

  // 데스크톱 모드일 경우 `web_home_page.dart`를 호출
  if (screenWidth > 768) {
    return WebHomePage(); // 데스크톱 전용 페이지
  }

  // 모바일 모드일 경우 기존 코드 유지
  return Scaffold(
    key: _scaffoldKey,
    backgroundColor: Colors.white,
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Icon(Icons.local_hospital_outlined, color: Colors.black),
      backgroundColor: const Color(0xFFFFF9C4),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
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
          child: _popupHandler.buildImageAnimationWithTouch(context, (newImagePath) {
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
          icon: Icon(Icons.medical_services_outlined),
          label: '내과',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital_outlined),
          label: '외과',
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
          '내과',
          [
            {'icon': Icons.dark_mode, 'title': '수면'},
            {'icon': Icons.restaurant, 'title': '식단'},
            {'icon': Icons.water_drop_outlined, 'title': '수분'},
          ],
        ),
      );
    case 1:
      return ListView(
        padding: EdgeInsets.zero,
        children: _buildDrawerItems(
          '외과',
          [
            {'icon': FontAwesomeIcons.tooth, 'title': '치아건강'},
            {'icon': FontAwesomeIcons.heartPulse, 'title': '혈압'},
            {'icon': FontAwesomeIcons.bandage, 'title': '상처'},
          ],
        ),
      );
    default:
      return Container();
  }
}

List<Widget> _buildDrawerItems(String title, List<Map<String, dynamic>> items) {
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
    }).toList(),
  ];
}
}