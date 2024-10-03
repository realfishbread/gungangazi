// mobile_home_page.dart
import 'package:example4/profile2.dart';
import 'package:example4/sorhkPage.dart';
import 'package:flutter/material.dart';
import 'PopupHandler.dart';
import 'ProfilePage.dart';
import 'SupplementsPage.dart';
import 'SleepPage.dart';
import 'WaterDrink.dart';
import 'MealPage.dart';
import 'ChatPage.dart';
import 'loginPge.dart';

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key});

  @override
  _MobileHomePageState createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  int _selectedIndex = 0;
  List<dynamic> _listData = [];
  late PopupHandler _popupHandler;

  @override
  void initState() {
    super.initState();
    _popupHandler = PopupHandler(listData: _listData);
  }

  @override
  void dispose() {
    _popupHandler.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SorhkPage()), // 내과 첫 번째 페이지
      );
    } else if (_selectedIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MealPage()), // 외과 첫 번째 페이지
      );
    } else if (_selectedIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SupplementsPage()), // 캘린더 페이지
      );
    } else if (_selectedIndex == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Profile2()), // 마이 페이지
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            MaterialPageRoute(builder: (context) => const ChatPage()),
          );
        },
        backgroundColor: const Color(0xFFFFF9C4),
        child: const Icon(Icons.chat),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
