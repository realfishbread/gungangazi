import 'package:flutter/material.dart';
import '../dto/profile_dto.dart';
import '../repositories/profile_repository.dart';
import '../services/dio_service.dart'; // DioService 임포트
import 'loginPge.dart'; // 파일명 확인
import 'EditPage.dart';

class Profile2 extends StatefulWidget {
  final String username; // 로그인된 사용자의 username을 전달받는 필드

  const Profile2({super.key, required this.username}); // username을 필수 인자로 받도록 설정

  @override
  _Profile2State createState() => _Profile2State();
}

class _Profile2State extends State<Profile2> {
  late ProfileRepository _profileRepository;
  ProfileDto? _profile; // 프로필 정보를 저장할 변수
  bool isLoading = true; // 데이터 로딩 상태

  // 기본 프로필 정보
  final ProfileDto defaultProfile = ProfileDto(
    username: '기본아이디',
    realname: '기본이름',
    email: '기본이메일@example.com',
    height: '170cm',
    weight: '70kg',
    gender: '남성',
  );

  @override
  void initState() {
    super.initState();
    DioService dioService = DioService(); // DioService 인스턴스 생성
    _profileRepository = ProfileRepository(dioService: dioService); // Dio 객체 주입
    fetchProfile(); // 프로필 정보 가져오기
  }

  // 서버에서 프로필 정보를 가져오는 함수
  Future<void> fetchProfile() async {
    setState(() {
      isLoading = true;
    });

    // widget.username을 사용하여 로그인된 사용자의 프로필 정보 가져오기
    ProfileDto? profile = await _profileRepository.fetchProfile(widget.username);
    setState(() {
      _profile = profile ?? defaultProfile; // 프로필이 없을 경우 기본 프로필 사용
      isLoading = false;
    });
  }

  // 서버로 수정된 프로필 데이터를 보내는 함수
  Future<void> saveProfile(String fieldName, String newValue) async {
    bool success = await _profileRepository.updateProfile(widget.username, fieldName, newValue);
    if (success) {
      // 성공적으로 저장하면 프로필 정보를 다시 가져옴
      fetchProfile();
    } else {
      // 에러 처리
      throw Exception('Failed to save profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 설정', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFF9C4),
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 데이터 로딩 중일 때 로딩 스피너 표시
          : buildProfileContent(), // 프로필 내용 표시
    );
  }

 Widget buildProfileContent() {
  // 기본 프로필 정보가 없을 경우 기본값을 사용
  final profile = _profile ?? defaultProfile;

  return Container(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Stack(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage('assets/profile_placeholder.png'),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.black),
                  onPressed: () {
                    // 사진 변경 기능 추가 예정
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Divider(color: Colors.black),
        _buildProfileItem('아이디', profile.username, null),
        _buildProfileItem('이름', profile.realname, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPage(
                fieldName: '이름',
                currentValue: profile.realname,
                onSave: (fieldName, newValue) async {
                  await saveProfile(fieldName, newValue);
                },
              ),
            ),
          );
        }),
        _buildProfileItem('이메일', profile.email, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPage(
                fieldName: '이메일',
                currentValue: profile.email,
                onSave: (fieldName, newValue) async {
                  await saveProfile(fieldName, newValue);
                },
              ),
            ),
          );
        }),
        _buildProfileItem('키', profile.height, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPage(
                fieldName: '키',
                currentValue: profile.height,
                onSave: (fieldName, newValue) async {
                  await saveProfile(fieldName, newValue);
                },
              ),
            ),
          );
        }),
        _buildProfileItem('몸무게', profile.weight, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditPage(
                fieldName: '몸무게',
                currentValue: profile.weight,
                onSave: (fieldName, newValue) async {
                  await saveProfile(fieldName, newValue);
                },
              ),
            ),
          );
        }),
        _buildProfileItem('성별', profile.gender, null),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text('로그아웃', style: TextStyle(color: Colors.black)),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildProfileItem(String title, String value, VoidCallback? onEdit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              if (onEdit != null) // 수정 버튼이 필요한 항목만 표시
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: onEdit,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
