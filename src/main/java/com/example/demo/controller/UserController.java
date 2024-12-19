package com.example.demo.controller;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;  // JWT 발급 서비스 (새로 추가)
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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.DTO.LoginRequestDto;
import com.example.demo.DTO.ProfileDto;
import com.example.demo.DTO.UserDTO;
import com.example.demo.entity.EmailToken;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import com.example.demo.repository.userHealth.EmailTokenRepository;
import com.example.demo.service.AuthService;
import com.example.demo.service.EmailService;
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
    private EmailService emailService;

    @Autowired
    private AuthService authService;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;  // JWT 토큰 발급 서비스 (새로 추가)


    @Autowired
    private EmailTokenRepository emailTokenRepository; // 이메일 토큰 저장소

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

    @PostMapping("/request-email-verification")
    public ResponseEntity<?> requestEmailVerification(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        if (email == null || email.isEmpty()) {
            return ResponseEntity.badRequest().body("이메일을 입력해 주세요.");
        }

        // 이메일 인증 코드 생성 및 이메일 전송
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new IllegalArgumentException("이메일이 존재하지 않습니다."));

        // 6자리 인증 코드 생성
        String verificationCode = emailService.generateVerificationCode();
        LocalDateTime expirationTime = LocalDateTime.now().plusMinutes(10);

        // 인증 코드를 데이터베이스에 저장
        emailTokenRepository.save(new EmailToken(verificationCode, expirationTime, email));

        // 이메일 전송
        emailService.sendEmailWithCode(email, "이메일 인증 코드", verificationCode);
        return ResponseEntity.ok(Map.of("message", "이메일 인증 코드를 발송했습니다."));
    }



    // 이메일 인증
    // Step 1: 이메일로 인증 코드 전송
    @PostMapping("/send-verification-code")
    public ResponseEntity<String> sendVerificationCode(@RequestParam String email) {
        authService.sendVerificationCode(email);
        return ResponseEntity.ok("인증 코드가 이메일로 전송되었습니다.");
    }
    
    // Step 2: 인증 코드 검증
    @PostMapping("/verify-code")
    public ResponseEntity<String> verifyCode(@RequestParam String email, @RequestParam String code) {
        boolean isVerified = authService.verifyCode(email, code);
        if (isVerified) {
            return ResponseEntity.ok("이메일 인증이 완료되었습니다.");
        } else {
            return ResponseEntity.badRequest().body("인증 번호가 유효하지 않거나 만료되었습니다.");
        }
    }

    // Step 3: 최종 사용자 저장
    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestParam String email, @RequestBody UserDTO userDTO) {
        boolean isVerified = authService.registerUserIfVerified(email, userDTO);

        if (isVerified) {
            // 검증이 끝난 경우, signUp 메서드 호출
            return signUp(userDTO);
        } else {
            return ResponseEntity.badRequest().body("이메일 인증이 완료되지 않았습니다.");
        }
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
        if (profileDto.getProfile_image() != null) {
            existingUser.setProfile_image(profileDto.getProfile_image()); // Base64 이미지 저장
        }
        if (profileDto.getAge() != null) {
            existingUser.setAge(profileDto.getAge()); // Base64 이미지 저장
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


