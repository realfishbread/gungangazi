package com.example.demo.controller;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;  // JWT 발급 서비스 (새로 추가)
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.DTO.LoginRequestDto;
import com.example.demo.DTO.ProfileDto;
import com.example.demo.DTO.UserDTO;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.JwtTokenProvider;
import com.example.demo.service.UserService;

@RestController
@RequestMapping
public class UserController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    @Autowired
    private UserService userService;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;  // JWT 토큰 발급 서비스 (새로 추가)

    // 회원가입
    @PostMapping("/signup")
    public ResponseEntity<?> signUp(@RequestBody UserDTO userDTO) {
        if (userRepository.existsByUsername(userDTO.getUsername())) {
           Map<String, Object> errorResponse = new HashMap<>();
           errorResponse.put("message", "아이디가 이미 존재합니다.");
           return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }
       // UserDTO를 User 엔티티로 변환하여 저장
        User user = userDTO.toEntity();
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
        public ResponseEntity<?> login(@RequestBody LoginRequestDto loginRequest) {
        Optional<User> existingUserOptional = userRepository.findByUsername(loginRequest.getUsername());

        if (existingUserOptional.isEmpty() || !passwordEncoder.matches(loginRequest.getPassword(), existingUserOptional.get().getPassword())) {
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("message", "아이디 또는 비밀번호가 잘못되었습니다.");
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(errorResponse);
        }

        // 로그인 성공 후 JWT 토큰 발급
        String token = jwtTokenProvider.createToken(loginRequest.getUsername());

        Map<String, Object> response = new HashMap<>();
        response.put("message", "로그인 성공");
        response.put("token", token);
        return ResponseEntity.ok(response);
    }

    // UserController.java

    @GetMapping("/profile")
    public ResponseEntity<?> getProfile(Authentication authentication) {
        String username = authentication.getName(); // 현재 로그인한 사용자의 이름 가져오기
        ProfileDto profileDto = userService.getUserProfileByUsername(username);
        return ResponseEntity.ok(profileDto);
    }
    

    @PutMapping("/{username}/update")
    public ResponseEntity<?> updateUser(@PathVariable String username, @RequestBody ProfileDto profileDto) {
        Optional<User> userOptional = userRepository.findByUsername(username);
    
        if (userOptional.isEmpty()) {
            return createErrorResponse("사용자를 찾을 수 없습니다.", 404);
        }
    
        User existingUser = userOptional.get();
        if (profileDto.getRealname() != null) {
            existingUser.setRealname(profileDto.getRealname());
        }
        if (profileDto.getEmail() != null) {
            existingUser.setEmail(profileDto.getEmail());
        }
        if (profileDto.getHeight() != null) {
            existingUser.setHeight(profileDto.getHeight());
        }
        if (profileDto.getWeight() != null) {
            existingUser.setWeight(profileDto.getWeight());
        }
        if (profileDto.getGender() != null) {
            existingUser.setGender(profileDto.getGender());
        }
        if (profileDto.getProfileImage() != null) {
            existingUser.setProfileImage(profileDto.getProfileImage()); // Base64 이미지 저장
        }
    
        userRepository.save(existingUser);
    
        return ResponseEntity.ok(createSuccessResponse("사용자 정보가 업데이트되었습니다."));
    }

    // 사용자 삭제
    @DeleteMapping("/{username}/delete")
    public ResponseEntity<?> deleteUser(@PathVariable String username) {
        Optional<User> userOptional = userRepository.findByUsername(username);

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


