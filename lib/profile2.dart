import 'package:flutter/material.dart';
import '../dto/profile_dto.dart';
import '../repositories/profile_repository.dart';
import 'loginPge.dart';

class Profile2 extends StatefulWidget {
  const Profile2({super.key});

  @override
  _Profile2State createState() => _Profile2State();
}

class _Profile2State extends State<Profile2> {
  late ProfileRepository _profileRepository;
  ProfileDto? _profile; // 프로필 정보를 저장할 변수
  bool isLoading = true; // 데이터 로딩 상태

  // 기본 프로필 정보
  final ProfileDto defaultProfile = ProfileDto(
    userId: '기본아이디',
    name: '기본이름',
    email: '기본이메일@example.com',
    height: '170cm',
    weight: '70kg',
    gender: '남성',
  );

  @override
  void initState() {
    super.initState();
    _profileRepository = ProfileRepository();
    fetchProfile(); // 프로필 정보 가져오기
  }

  // 서버에서 프로필 정보를 가져오는 함수
  Future<void> fetchProfile() async {
    setState(() {
      isLoading = true;
    });

    ProfileDto? profile = await _profileRepository.fetchProfile();
    setState(() {
      _profile = profile ?? defaultProfile; // 프로필이 없을 경우 기본 프로필 사용
      isLoading = false;
    });
  }

  // 서버로 수정된 프로필 데이터를 보내는 함수
  Future<void> saveProfile(String fieldName, String newValue) async {
    bool success = await _profileRepository.updateProfile(fieldName, newValue);
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
          _buildProfileItem('아이디', profile.userId, null),
          _buildProfileItem('이름', profile.name, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPage(fieldName: '이름', currentValue: profile.name, onSave: saveProfile),
              ),
            );
          }),
          _buildProfileItem('이메일', profile.email, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPage(fieldName: '이메일', currentValue: profile.email, onSave: saveProfile),
              ),
            );
          }),
          _buildProfileItem('키', profile.height, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPage(fieldName: '키', currentValue: profile.height, onSave: saveProfile),
              ),
            );
          }),
          _buildProfileItem('몸무게', profile.weight, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditPage(fieldName: '몸무게', currentValue: profile.weight, onSave: saveProfile),
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


class EditPage extends StatefulWidget {
  final String fieldName;
  final String currentValue;
  final Function(String fieldName, String newValue) onSave; // 수정된 값을 저장하는 콜백 함수

  const EditPage({super.key, required this.fieldName, required this.currentValue, required this.onSave});

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController _controller;
  bool _isSaving = false; // 저장 중인지 여부를 나타내는 상태

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  Future<void> _saveProfile() async {
    if (_controller.text.isEmpty) {
      // 입력값이 비어있을 때 경고 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('값을 입력해주세요.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      _isSaving = true; // 저장 중 상태 설정
    });

    await widget.onSave(widget.fieldName, _controller.text);

    setState(() {
      _isSaving = false; // 저장 완료 상태로 변경
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.fieldName} 수정', style: const TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFFFF9C4),
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: widget.fieldName,
                labelStyle: const TextStyle(color: Colors.black),
                border: const OutlineInputBorder(),
              ),
              style: const TextStyle(color: Colors.black),
              onSubmitted: (value) => _saveProfile(), // 엔터키 입력 시 자동 저장
            ),
            const SizedBox(height: 20),
            _isSaving
                ? const CircularProgressIndicator() // 저장 중일 때 로딩 스피너 표시
                : TextButton(
              onPressed: _saveProfile,
              child: const Text('저장', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
