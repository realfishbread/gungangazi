package com.example.demo.controller;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @PostMapping("/signup")
    public ResponseEntity<?> signUp(@RequestBody User user) {
        if (userRepository.existsByUsername(user.getUsername())) {  // getUsername 메서드 사용
            Map<String, String> response = new HashMap<>();
            response.put("message", "아이디가 이미 존재합니다.");
            return ResponseEntity.badRequest().body(response);
        }

        user.setPassword("암호화된 비밀번호");  // 적절한 암호화 처리 필요
        userRepository.save(user);

        Map<String, String> response = new HashMap<>();
        response.put("message", "회원가입 성공");
        return ResponseEntity.ok(response);
    }
}

