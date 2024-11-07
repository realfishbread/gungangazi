import 'package:flutter/material.dart';
import '../dto/profile_dto.dart';
import '../repositories/profile_repository.dart';
import '../services/dio_service.dart';
import '../services/TokenService.dart'; // TokenService를 임포트
import 'loginPge.dart';
import 'EditPage.dart';

class Profile2 extends StatefulWidget {
  final String username;

  const Profile2({super.key, required this.username});

  @override
  _Profile2State createState() => _Profile2State();
}

class _Profile2State extends State<Profile2> {
  late ProfileRepository _profileRepository;
  final TokenService _tokenService = TokenService(); // TokenService 인스턴스 생성
  ProfileDto? _profile;
  bool isLoading = true;

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
    _initialize(); // 비동기 초기화 함수 호출
  }

  // 비동기 초기화 함수
  Future<void> _initialize() async {
    String? token = await _tokenService.getToken(); // TokenService에서 토큰 가져오기
    DioService dioService = DioService(token: token); // Token 전달하여 DioService 초기화
    _profileRepository = ProfileRepository(dioService: dioService, tokenService: _tokenService); // TokenService 전달
    fetchProfile();
  }

  // 서버에서 프로필 정보를 가져오는 함수
  Future<void> fetchProfile() async {
    setState(() {
      isLoading = true;
    });

    ProfileDto? profile = await _profileRepository.fetchProfile(widget.username);
    setState(() {
      _profile = profile ?? defaultProfile;
      isLoading = false;
    });
  }

  // 서버로 수정된 프로필 데이터를 보내는 함수
  Future<void> saveProfile(String fieldName, String newValue) async {
    final updatedProfile = ProfileDto(
      username: _profile?.username ?? defaultProfile.username,
      realname: fieldName == '이름' ? newValue : _profile?.realname ?? defaultProfile.realname,
      email: fieldName == '이메일' ? newValue : _profile?.email ?? defaultProfile.email,
      height: fieldName == '키' ? newValue : _profile?.height ?? defaultProfile.height,
      weight: fieldName == '몸무게' ? newValue : _profile?.weight ?? defaultProfile.weight,
      gender: _profile?.gender ?? defaultProfile.gender,
    );

    bool success = await _profileRepository.updateProfile(
        widget.username,
        updatedProfile.toJson() // toJson 메서드 사용하여 Map 형식으로 변환
    );
    if (success) {
      await fetchProfile(); // 업데이트 후 프로필 정보를 다시 가져오기
    } else {
      print('파일 저장을 실패했습니다');
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
          ? const Center(child: CircularProgressIndicator())
          : buildProfileContent(),
    );
  }

  Widget buildProfileContent() {
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
          _buildProfileItem('아이디', profile.username ?? '기본아이디', null),
          _buildProfileItem('이름', profile.realname ?? '기본이름', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPage(
                  fieldName: '이름',
                  currentValue: profile.realname ?? '기본이름',
                  onSave: (fieldName, newValue) async {
                    await saveProfile(fieldName, newValue);
                  },
                ),
              ),
            );
          }),
          _buildProfileItem('이메일', profile.email ?? '기본이메일@example.com', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPage(
                  fieldName: '이메일',
                  currentValue: profile.email ?? '기본이메일@example.com',
                  onSave: (fieldName, newValue) async {
                    await saveProfile(fieldName, newValue);
                  },
                ),
              ),
            );
          }),
          _buildProfileItem('키', profile.height ?? '170cm', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPage(
                  fieldName: '키',
                  currentValue: (profile.height ?? '170cm').replaceAll('cm', ''), // 'cm' 제거하여 숫자만 전달
                  onSave: (fieldName, newValue) async {
                    await saveProfile(fieldName, newValue);
                  },
                ),
              ),
            );
          }),
          _buildProfileItem('몸무게', profile.weight ?? '70kg', () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPage(
                  fieldName: '몸무게',
                  currentValue: (profile.weight ?? '70kg').replaceAll('kg', ''), // 'kg' 제거하여 숫자만 전달
                  onSave: (fieldName, newValue) async {
                    await saveProfile(fieldName, newValue);
                  },
                ),
              ),
            );
          }),

          _buildProfileItem('성별', profile.gender ?? '남성', null),
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
              if (onEdit != null)
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