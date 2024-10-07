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

    @PostMapping("/login")
public ResponseEntity<?> login(@RequestBody User user) {
    User existingUser = userRepository.findByUsername(user.getUsername());
    
    if (existingUser == null || !existingUser.getPassword().equals(user.getPassword())) {
        Map<String, String> response = new HashMap<>();
        response.put("message", "아이디 또는 비밀번호가 잘못되었습니다.");
        return ResponseEntity.badRequest().body(response);
    }

    Map<String, String> response = new HashMap<>();
    response.put("message", "로그인 성공");
    return ResponseEntity.ok(response);
}

    @GetMapping("/{username}")
public ResponseEntity<?> getUser(@PathVariable String username) {
    User user = userRepository.findByUsername(username);
    
    if (user == null) {
        Map<String, String> response = new HashMap<>();
        response.put("message", "사용자를 찾을 수 없습니다.");
        return ResponseEntity.badRequest().body(response);
    }
    
    return ResponseEntity.ok(user);
}

    @PutMapping("/{username}")
public ResponseEntity<?> updateUser(@PathVariable String username, @RequestBody User updatedUser) {
    User existingUser = userRepository.findByUsername(username);
    
    if (existingUser == null) {
        Map<String, String> response = new HashMap<>();
        response.put("message", "사용자를 찾을 수 없습니다.");
        return ResponseEntity.badRequest().body(response);
    }
    
    existingUser.setPassword(updatedUser.getPassword());  // 비밀번호도 적절히 암호화 필요
    userRepository.save(existingUser);

    Map<String, String> response = new HashMap<>();
    response.put("message", "사용자 정보가 업데이트되었습니다.");
    return ResponseEntity.ok(response);
}

    @DeleteMapping("/{username}")
public ResponseEntity<?> deleteUser(@PathVariable String username) {
    User existingUser = userRepository.findByUsername(username);
    
    if (existingUser == null) {
        Map<String, String> response = new HashMap<>();
        response.put("message", "사용자를 찾을 수 없습니다.");
        return ResponseEntity.badRequest().body(response);
    }
    
    userRepository.delete(existingUser);

    Map<String, String> response = new HashMap<>();
    response.put("message", "사용자가 삭제되었습니다.");
    return ResponseEntity.ok(response);
}

   

@Autowired
private BCryptPasswordEncoder passwordEncoder;


}

