package com.example.demo.controller;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;  // JWT 발급 서비스 (새로 추가)
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.JwtTokenProvider;

@RestController
@RequestMapping
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;  // JWT 토큰 발급 서비스 (새로 추가)

    // 회원가입
    @PostMapping("/signup")
    public ResponseEntity<?> signUp(@RequestBody User user) {
        if (userRepository.existsByUsername(user.getUsername())) {
            return createErrorResponse("아이디가 이미 존재합니다.", 400);
        }

       // UserDTO를 User 엔티티로 변환하여 저장
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        userRepository.save(user);

        // JWT 토큰 발급
        String token = jwtTokenProvider.createToken(user.getUsername());

        Map<String, Object> response = new HashMap<>();
        response.put("message", "회원가입 성공");
        response.put("token", token);
        return ResponseEntity.ok(response);
    }

    // 로그인
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody User user) {
        Optional<User> existingUserOptional = userRepository.findByUsername(user.getUsername());

        if (existingUserOptional.isEmpty() || !passwordEncoder.matches(user.getPassword(), existingUserOptional.get().getPassword())) {
            return createErrorResponse("아이디 또는 비밀번호가 잘못되었습니다.", 400);
        }

        // 로그인 성공 후 JWT 토큰 발급
        String token = jwtTokenProvider.createToken(user.getUsername());

        Map<String, Object> response = new HashMap<>();
        response.put("message", "로그인 성공");
        response.put("token", token);
        return ResponseEntity.ok(response);
    }

    // 사용자 정보 조회
    @GetMapping("/{id}")
    public ResponseEntity<?> getUser(@PathVariable Long id) {
        Optional<User> userOptional = userRepository.findById(id);

        if (userOptional.isEmpty()) {
            return createErrorResponse("사용자를 찾을 수 없습니다.", 404);
        }

        return ResponseEntity.ok(userOptional.get());
    }

    // 사용자 정보 업데이트
    @PutMapping("/{id}")
    public ResponseEntity<?> updateUser(@PathVariable Long id, @RequestBody User updatedUser) {
        Optional<User> userOptional = userRepository.findById(id);

        if (userOptional.isEmpty()) {
            return createErrorResponse("사용자를 찾을 수 없습니다.", 404);
        }

        User existingUser = userOptional.get();
        existingUser.setPassword(passwordEncoder.encode(updatedUser.getPassword()));  // 비밀번호 암호화
        userRepository.save(existingUser);

        return ResponseEntity.ok(createSuccessResponse("사용자 정보가 업데이트되었습니다."));
    }

    // 사용자 삭제
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
        Optional<User> userOptional = userRepository.findById(id);

        if (userOptional.isEmpty()) {
            return createErrorResponse("사용자를 찾을 수 없습니다.", 404);
        }

        userRepository.delete(userOptional.get());

        return ResponseEntity.ok(createSuccessResponse("사용자가 삭제되었습니다."));
    }

    // 성공 응답 생성
    private Map<String, Object> createSuccessResponse(String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("message", message);
        return response;
    }

    // 에러 응답 생성
    private ResponseEntity<?> createErrorResponse(String message, int status) {
        Map<String, String> response = new HashMap<>();
        response.put("message", message);
        return ResponseEntity.status(status).body(response);
    }
}


