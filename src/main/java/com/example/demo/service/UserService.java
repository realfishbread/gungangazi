package com.example.demo.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import com.example.demo.DTO.UserDTO;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;  // BCryptPasswordEncoder 추가

    // 회원가입 로직
    public User registerUser(UserDTO userDTO) {
        // 비밀번호 암호화
        String encryptedPassword = passwordEncoder.encode(userDTO.getPassword());
        userDTO.setPassword(encryptedPassword); // 암호화된 비밀번호 설정

        // DTO를 엔티티로 변환하고 데이터베이스에 저장
        User user = userDTO.toEntity();
        return userRepository.save(user);
    }

    public User login(String username, String password) throws Exception {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new Exception("유저를 찾을 수 없습니다."));

        // 입력한 비밀번호와 암호화된 비밀번호를 비교 (BCryptPasswordEncoder의 matches 메서드 사용)
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new Exception("사용 불가한 비밀번호입니다.");
        }

        return user;
    }
}
