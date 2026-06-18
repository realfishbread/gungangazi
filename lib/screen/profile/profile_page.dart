import 'package:flutter/material.dart';
import 'package:gunganghazi/repositories/auth/auth_repository.dart';
import 'package:gunganghazi/view_model/google_view_model.dart';
import '../../dto/auth/profile_dto.dart';
import '../../repositories/auth/profile_repository.dart';
import '../../core_services/dio_service.dart';
import '../../core_services/token_service.dart';
import '../auth/login_page.dart';
import 'edit_personal_info.dart';
import 'image/image_picker.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'image/image_picker_web.dart';
import 'image/image_picker_mobile.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../widget/alert.dart';
import '../../view_model/google_view_model.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final VoidCallback onProfileUpdated;

  const ProfilePage({
    super.key,
    required this.username,
    required this.onProfileUpdated,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Uint8List? _imageData;
  late ProfileRepository _profileRepository;
  late AuthRepository _authRepository;
  final TokenService _tokenService = TokenService();
  ProfileDto? _profile;
  bool isLoading = true;
  late ScrollController _scrollController;
  late GoogleViewModel _googleViewModel;

  final ProfileDto defaultProfile = ProfileDto(
    username: '기본아이디',
    realname: '기본이름',
    email: '기본이메일@example.com',
    height: '170cm',
    weight: '70kg',
    gender: '남성',
    age: '25', // 기본 age 값 추가
    is_google_user: false,
  );

  @override
  void initState() {
    super.initState();
    _googleViewModel = GoogleViewModel(AuthRepository()); // ✅ 의존성 주입
    _scrollController = ScrollController();
    _initialize();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
    await updateProfileData();
  }

  Future<void> updateProfileData({String? fieldName, dynamic newValue}) async {
    final updatedProfile = ProfileDto(
      username: _profile?.username ?? defaultProfile.username,
      realname: fieldName == '이름' ? newValue : _profile?.realname ?? defaultProfile.realname,
      email: fieldName == '이메일' ? newValue : _profile?.email ?? defaultProfile.email,
      height: fieldName == '키' ? newValue : _profile?.height ?? defaultProfile.height,
      weight: fieldName == '몸무게' ? newValue : _profile?.weight ?? defaultProfile.weight,
      gender: _profile?.gender ?? defaultProfile.gender,
      age: fieldName == '나이' ? newValue : _profile?.age ?? defaultProfile.age,
      profile_image: _imageData != null ? base64Encode(_imageData!) : _profile?.profile_image,
      is_google_user: _profile?.is_google_user ??defaultProfile.is_google_user,
    );

  

    bool success = await _profileRepository.updateProfile(widget.username, updatedProfile.toJson());

    if (success) {
      widget.onProfileUpdated();
      await fetchProfile();
    } else {
      showErrorDialog(context, '프로필 업데이트 실패');
    }
  }

  Future<void> fetchProfile() async {
    setState(() {
      isLoading = true;
    });

    ProfileDto? profile = await _profileRepository.fetchProfile(widget.username);
    
    setState(() {
      _profile = profile ?? defaultProfile;
      if (_profile?.profile_image != null) {
        _imageData = base64Decode(_profile!.profile_image!);
      }
      isLoading = false;
    });
  }
 
  

  
  void _linkSamsungHealth() async {
    // TODO: Implement Samsung Health linking logic
    print("삼성 헬스 연동");
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
          : WebSmoothScroll(
              controller: _scrollController,
              scrollSpeed: 2.1, // additional scroll extent for smooth animation
              scrollAnimationLength: 800, // duration of animation of scroll in milliseconds
              curve: Curves.easeInOutCirc, // curve of the animation
              child: SingleChildScrollView(
                controller: _scrollController,
                child: buildProfileContent(),
              ),
            ),
    );
  }

  Widget buildProfileContent() {
    final profile = _profile ?? defaultProfile;
    

    return SingleChildScrollView(
      child: Container(
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
                        ? MemoryImage(_imageData!)
                        : AssetImage('assets/place_holder.png') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.black),
                      onPressed: _pickImage,
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
                  builder: (context) => EditPersonalInfo(
                    fieldName: '이름',
                    currentValue: profile.realname ?? '기본이름',
                    onSave: (fieldName, newValue) async {
                      await updateProfileData(fieldName: fieldName, newValue: newValue);
                    },
                  ),
                ),
              );
            }),
            _buildProfileItem('이메일', profile.email ?? '기본이메일@example.com', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPersonalInfo(
                    fieldName: '이메일',
                    currentValue: profile.email ?? '기본이메일@example.com',
                    onSave: (fieldName, newValue) async {
                      await updateProfileData(fieldName: fieldName, newValue: newValue);
                    },
                  ),
                ),
              );
            }),
            _buildProfileItem('키', profile.height ?? '170cm', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPersonalInfo(
                    fieldName: '키',
                    currentValue: (profile.height ?? '170cm').replaceAll('cm', ''),
                    onSave: (fieldName, newValue) async {
                      await updateProfileData(fieldName: fieldName, newValue: newValue);
                    },
                  ),
                ),
              );
            }),
            _buildProfileItem('몸무게', profile.weight ?? '70kg', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditPersonalInfo(
                    fieldName: '몸무게',
                    currentValue: (profile.weight ?? '70kg').replaceAll('kg', ''),
                    onSave: (fieldName, newValue) async {
                      await updateProfileData(fieldName: fieldName, newValue: newValue);
                    },
                  ),
                ),
              );
            }),
             _buildProfileItem('나이', profile.age ?? '0', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => EditPersonalInfo(
                    fieldName: '나이',
                    currentValue: (profile.age ?? '33').replaceAll('세', ''),
                    onSave: (fieldName, newValue) async {
                      await updateProfileData(fieldName: fieldName, newValue: newValue);
                    },
                  ),
                ),
              );
            }),
            _buildProfileItem('성별', profile.gender ?? '남성', null),
           


            const SizedBox(height: 20),

          Center(
            child: Column(
              children: [
                
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _linkSamsungHealth,
                  icon: const Icon(Icons.health_and_safety, color: Colors.green),
                  label: const Text('삼성 헬스 연동', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
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
            const SizedBox(height: 50),
            Center(
              child: Column(
                children: [
                  Text(
                    '건강아지 | 고객 지원 문의 : +82 1234 5678 및 yoonh12288@gmail.com',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
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
