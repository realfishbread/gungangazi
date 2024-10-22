package com.example.demo.controller;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/users")
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    // 회원가입
    @PostMapping("/signup")
    public ResponseEntity<?> signUp(@RequestBody User user) {
        if (userRepository.existsByUsername(user.getUsername())) {
            Map<String, String> response = new HashMap<>();
            response.put("message", "아이디가 이미 존재합니다.");
            return ResponseEntity.badRequest().body(response);
        }

        // 비밀번호 암호화
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        userRepository.save(user);

        Map<String, String> response = new HashMap<>();
        response.put("message", "회원가입 성공");
        return ResponseEntity.ok(response);
    }

    // 로그인
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody User user) {
        Optional<User> existingUserOptional = userRepository.findByUsername(user.getUsername());

        if (existingUserOptional.isEmpty() || !passwordEncoder.matches(user.getPassword(), existingUserOptional.get().getPassword())) {
            Map<String, String> response = new HashMap<>();
            response.put("message", "아이디 또는 비밀번호가 잘못되었습니다.");
            return ResponseEntity.badRequest().body(response);
        }

        Map<String, String> response = new HashMap<>();
        response.put("message", "로그인 성공");
        return ResponseEntity.ok(response);
    }

    // 사용자 정보 조회
    @GetMapping("/{id}")
    public ResponseEntity<?> getUser(@PathVariable Long id) {
        Optional<User> userOptional = userRepository.findById(id);

        if (userOptional.isEmpty()) {
            Map<String, String> response = new HashMap<>();
            response.put("message", "사용자를 찾을 수 없습니다.");
            return ResponseEntity.badRequest().body(response);
        }

        return ResponseEntity.ok(userOptional.get());
    }

    // 사용자 정보 업데이트
    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Long id, @RequestBody User updatedUser) {
        Optional<User> userOptional = userRepository.findById(id);

        if (userOptional.isEmpty()) {
            Map<String, String> response = new HashMap<>();
            response.put("message", "사용자를 찾을 수 없습니다.");
            return ResponseEntity.badRequest().body(response);
        }

        User existingUser = userOptional.get();
        existingUser.setPassword(passwordEncoder.encode(updatedUser.getPassword())); // 비밀번호 암호화
        userRepository.save(existingUser);

        Map<String, String> response = new HashMap<>();
        response.put("message", "사용자 정보가 업데이트되었습니다.");
        return ResponseEntity.ok(response);
    }

    // 사용자 삭제
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
        Optional<User> userOptional = userRepository.findById(id);

        if (userOptional.isEmpty()) {
            Map<String, String> response = new HashMap<>();
            response.put("message", "사용자를 찾을 수 없습니다.");
            return ResponseEntity.badRequest().body(response);
        }

        userRepository.delete(userOptional.get());

        Map<String, String> response = new HashMap<>();
        response.put("message", "사용자가 삭제되었습니다.");
        return ResponseEntity.ok(response);
    }
}


