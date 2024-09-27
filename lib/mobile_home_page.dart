// mobile_home_page.dart
import 'package:flutter/material.dart';
import 'PopupHandler.dart';
import 'ProfilePage.dart';
import 'SupplementsPage.dart';
import 'SleepPage.dart';
import 'WaterDrink.dart';
import 'MealPage.dart';
import 'ChatPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'LoginPage.dart'; // 로그인 페이지 임포트

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key});

  @override
  _MobileHomePageState createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> _listData = [];
  late PopupHandler _popupHandler;

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('http://your-api-url'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _listData = data['listData'];
        });
      } else {
        throw Exception('데이터를 가져오지 못했습니다.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    _popupHandler = PopupHandler(listData: _listData);
  }

  @override
  void dispose() {
    _popupHandler.dispose();
    super.dispose();
  }

  void _navigateToPage(BuildContext context, String title) {
    final routes = {
      '수면': const SleepPage(),
      '수분': const WaterDrink(),
      '식단': const MealPage(),
      '영양제': const SupplementsPage(),
    };

    final page = routes[title];
    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 0 || _selectedIndex == 1) {
      _scaffoldKey.currentState?.openEndDrawer();
    } else if (_selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SupplementsPage()),
      );
    } else if (_selectedIndex == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Icon(Icons.pets, color: Colors.black),
        backgroundColor: const Color(0xFFFFF9C4),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // 로그아웃 아이콘
            onPressed: () {
              // 로그아웃 버튼 클릭 시 로그인 페이지로 이동
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
      body: Center(
        child: _popupHandler.buildImageAnimationWithTouch(context, (newImagePath) {
          setState(() {});
        }),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        unselectedItemColor: Colors.black12,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatPage()), // 채팅 페이지로 이동
          );
        },
        backgroundColor: const Color(0xFFFFF9C4),
        child: const Icon(Icons.pets), // 원형 버튼 색상
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat, // FAB를 왼쪽 아래에 배치
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
              {'icon': Icons.person, 'title': '식단'},
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
              {'icon': Icons.person, 'title': '치아건강'},
              {'icon': Icons.person, 'title': '혈압'},
              {'icon': Icons.settings, 'title': '상처'},
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
        return ListTile(
          leading: Icon(item['icon'], color: Colors.black),
          title: Text(item['title'], style: const TextStyle(color: Colors.black)),
          onTap: () {
            Navigator.pop(context);
            _navigateToPage(context, item['title'] as String);
          },
        );
      }),
    ];
  }
}
