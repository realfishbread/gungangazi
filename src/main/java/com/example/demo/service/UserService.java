package com.example.demo.service;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;  // BCryptPasswordEncoder 추가

    // 회원가입 처리 메서드 (Optional, 만약 회원가입을 처리해야 한다면)
    public void registerUser(User user) {
        // 비밀번호 암호화
        String encodedPassword = passwordEncoder.encode(user.getPassword());
        user.setPassword(encodedPassword);
        userRepository.save(user);
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
