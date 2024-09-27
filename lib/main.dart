import 'package:example4/MealPage.dart';
import 'package:example4/splash/SplashPage.dart';
import 'package:flutter/material.dart';
import 'PopupHandler.dart';
import 'ProfilePage.dart';
import 'SupplementsPage.dart';
import 'SleepPage.dart'; // 수면 페이지 임포트
import 'WaterDrink.dart';
import 'StressPage.dart';
import 'MealPage.dart';
import 'BloodPressurePage.dart';
import 'TeethHealthPage.dart';
import 'WoundCarePage.dart'; // 필요한 페이지 임포트
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '건강아지', // MaterialApp의 title은 여전히 문자열이어야 합니다.
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: createMaterialColor(const Color(0xFFFFF9C4)),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFF9C4),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }

  // MaterialColor로 변경하는 함수
  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<dynamic> _listData = [];
  late PopupHandler _popupHandler;

  // API를 호출하는 함수
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

  // 페이지 네비게이션 처리 함수
  void _navigateToPage(BuildContext context, String title) {
    final routes = {
      '수면': SleepPage(),
      '수분': WaterDrink(),
      '스트레스': StressPage(),
      '식단': MealPage(),
      '영양제': SupplementsPage(),
      '혈압': BloodPressurePage(),
      '치아건강': TeethHealthPage(),
      '상처': WoundCarePage(),
    };

    final page = routes[title];
    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  // 내비게이션 아이템 선택시 처리
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 0 || _selectedIndex == 1) {
      // 내과나 외과 선택 시 드로어 열기
      _scaffoldKey.currentState?.openEndDrawer();
    } else if (_selectedIndex == 2) {
      // "캘린더" 선택 시 SupplementsPage로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SupplementsPage()),
      );
    } else if (_selectedIndex == 3) {
      // "마이 페이지" 선택 시 ProfilePage로 이동
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // GlobalKey 사용
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Icon(Icons.pets, color: Colors.black), // 텍스트 대신 아이콘 추가
        backgroundColor: const Color(0xFFFFF9C4),
        centerTitle: true, // 아이콘을 중앙에 배치
      ),
      endDrawer: SizedBox(
        width: 150,
        child: Drawer(
          child: _getDrawerContent(),
        ),
      ),
      body: Center(
        child: _popupHandler.buildVideoWithTouch(context, (newImagePath) {
          setState(() {
            // 선택된 이미지 경로 처리
          });
        }),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFFFF9C4),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.headphones),
            label: '내과',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: '외과',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: '마이 페이지',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black12,
        onTap: _onItemTapped,
      ),
    );
  }

  // 드로어 항목을 생성하는 함수
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
            Navigator.pop(context); // 드로어 닫기
            _navigateToPage(context, item['title'] as String); // 페이지 이동
          },
        );
      }).toList(),
    ];
  }
}
