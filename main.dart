import 'package:flutter/material.dart';
import 'HomePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '건강아지',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.brown, // 브라운 계열로 변경
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index >= 0) {
      _scaffoldKey.currentState?.openEndDrawer();
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('자가진단 리스트'),
          content: Text('여기에 어떻게 리스트 넣어요 ㅠㅠ'),
          actions: <Widget>[
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _getDrawerContent() {
    switch (_selectedIndex) {
      case 0:
        return ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.brown[800], // 브라운 계열로 변경
              ),
              child: Text(
                '정신과',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.brown[600]), // 브라운 계열로 변경
              title: Text('수면', style: TextStyle(color: Colors.brown[800])),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.brown[600]), // 브라운 계열로 변경
              title: Text('우울', style: TextStyle(color: Colors.brown[800])),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.brown[600]), // 브라운 계열로 변경
              title: Text('불안', style: TextStyle(color: Colors.brown[800])),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.brown[600]), // 브라운 계열로 변경
              title: Text('스트레스', style: TextStyle(color: Colors.brown[800])),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      case 1:
        return ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.brown[800], // 브라운 계열로 변경
              ),
              child: Text(
                '내과',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.food_bank, color: Colors.brown[600]), // 브라운 계열로 변경
              title: Text('식단', style: TextStyle(color: Colors.brown[800])),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.medication, color: Colors.brown[600]), // 브라운 계열로 변경
              title: Text('영양제', style: TextStyle(color: Colors.brown[800])),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.food_bank, color: Colors.brown[600]), // 브라운 계열로 변경
              title: Text('혈압', style: TextStyle(color: Colors.brown[800])),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      case 2:
        return ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.brown[800], // 브라운 계열로 변경
              ),
              child: Text(
                '외과',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.brown[600]), // 브라운 계열로 변경
              title: Text('치아건강', style: TextStyle(color: Colors.brown[800])),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.brown[600]), // 브라운 계열로 변경
              title: Text('혈압', style: TextStyle(color: Colors.brown[800])),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.brown[600]), // 브라운 계열로 변경
              title: Text('상처', style: TextStyle(color: Colors.brown[800])),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
          ],
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('건강아지', style: TextStyle(color: Colors.brown[900])),
        backgroundColor: Colors.brown[100],
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.brown[700]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
        ],
      ),
      endDrawer: Container(
        width: 150,
        child: Drawer(
          child: _getDrawerContent(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.headphones),
            label: '정신',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: '내과',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '외과',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.brown[700],
        unselectedItemColor: Colors.brown[500],
        onTap: _onItemTapped,
      ),
      body: Align(
        alignment: Alignment(0.0, 0.0), // 중앙 위치
        child: GestureDetector(
          onTap: _showDialog,
          child: Container(
            padding: EdgeInsets.all(16),
            child: Image.asset( // 이미지 추가
              'assets/sample_image.png', // 자신의 이미지 경로로 변경
              width: 200,
              height: 200,
            ),
          ),
        ),
      ),
    );
  }
}



