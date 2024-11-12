import 'package:flutter/material.dart';
import '../dto/profile_dto.dart';
import '../repositories/profile_repository.dart';
import '../services/dio_service.dart';
import '../services/TokenService.dart';
import 'loginPge.dart';
import 'EditPage.dart';
import 'conditional_imports.dart'; // 조건부 임포트 파일 추가
import 'dart:typed_data'; // Uint8List 타입을 위해 추가
import 'dart:convert'; // Base64 인코딩 및 디코딩을 위해 필요
import 'package:flutter/foundation.dart' show kIsWeb;
import 'image_picker_web.dart';
import 'image_picker_mobile.dart';

class Profile2 extends StatefulWidget {
  final String username;

  const Profile2({super.key, required this.username});

  @override
  _Profile2State createState() => _Profile2State();
}

class _Profile2State extends State<Profile2> {
  Uint8List? _imageData; // 서버에서 받은 Base64 이미지 데이터를 저장할 변수
  late ProfileRepository _profileRepository;
  final TokenService _tokenService = TokenService();
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
    _initialize();
  }

  // 비동기 초기화 함수
  Future<void> _initialize() async {
    String? token = await _tokenService.getToken();
    DioService dioService = DioService(token: token);
    _profileRepository = ProfileRepository(dioService: dioService, tokenService: _tokenService);
    fetchProfile();
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      _imageData = await pickImageWeb();
    } else {
      final pickedFile = await pickImageMobile();
      if (pickedFile != null) {
        final imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _imageData = imageBytes;
        });
      }
    }
    await _uploadProfileImage();
  }

  // 서버로 이미지 업로드
  Future<void> _uploadProfileImage() async {
    if (_imageData == null) return;

    final base64Image = base64Encode(_imageData!);

    final updatedData = {
      'username': _profile?.username ?? defaultProfile.username,
      'profileImage': base64Image, // Base64 인코딩된 이미지 추가
    };

    bool success = await _profileRepository.updateProfile(widget.username, updatedData);

    if (success) {
      await fetchProfile(); // 업데이트 후 프로필 정보를 다시 가져오기
    } else {
      print('이미지 업로드 실패');
    }
  }

  // 서버에서 프로필 정보를 가져오는 함수
  Future<void> fetchProfile() async {
    setState(() {
      isLoading = true;
    });

    ProfileDto? profile = await _profileRepository.fetchProfile(widget.username);
    setState(() {
      _profile = profile ?? defaultProfile;
      if (_profile?.profileImage != null) {
        _imageData = base64Decode(_profile!.profileImage!); // Base64 인코딩된 이미지를 디코딩하여 저장
      }
      isLoading = false;
    });
  }

  // 프로필 데이터 저장 함수
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
        updatedProfile.toJson()
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
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color.fromARGB(255, 240, 240, 240),
                  backgroundImage: _imageData != null
                      ? MemoryImage(_imageData!) // 서버에서 받은 이미지 또는 웹에서 선택한 이미지
                      : AssetImage('assets/place_holder.png') as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.black),
                    onPressed: _pickImage, // 이미지 선택
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
                  currentValue: (profile.height ?? '170cm').replaceAll('cm', ''),
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
                  currentValue: (profile.weight ?? '70kg').replaceAll('kg', ''),
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
