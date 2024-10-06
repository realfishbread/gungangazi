package com.example.demo.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository; // 데이터베이스와 상호작용하는 리포지토리

    @Autowired
    private BCryptPasswordEncoder passwordEncoder; // 비밀번호 암호화

    public void signUp(User user) {
        // 중복 아이디 검사
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new IllegalArgumentException("아이디가 이미 존재합니다.");
        }

        // 비밀번호 암호화
        user.setPassword(passwordEncoder.encode(user.getPassword()));

        // 사용자 저장
        userRepository.save(user);
    }
}
