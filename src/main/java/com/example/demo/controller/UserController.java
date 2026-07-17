package com.example.demo.controller;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.Random;
import java.util.concurrent.TimeUnit;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;  // JWT 발급 서비스 (새로 추가)
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.oauth2.core.user.OAuth2User;
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
import com.example.demo.DTO.VerifyCodeRequestDTO;
import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.EmailService;
import com.example.demo.service.EmailVerificationService;
import com.example.demo.service.JwtTokenProvider;
import com.example.demo.service.UserService;

@RestController
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
    private JwtTokenProvider jwtTokenProvider;  // JWT 토큰 발급 서비스 (새로 추가)


    
    @Autowired
    private StringRedisTemplate redisTemplate; // Redis 사용

    private static final long VERIFICATION_CODE_TTL = 10; // 인증 코드 TTL(분)

    @Autowired
    private EmailVerificationService emailVerificationService;


    // 회원가입
    @PostMapping("/signup")
    public ResponseEntity<?> signUp(@RequestBody UserDTO userDTO) {
        // 아이디 중복 확인
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
    
    /**
     * 이메일 인증 코드 요청
     */
    @PostMapping("/request-email-verification")
    public ResponseEntity<?> requestEmailVerification(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        if (email == null || email.isEmpty()) {
            return ResponseEntity.badRequest().body("이메일을 입력해 주세요.");
        }

        // Redis에서 기존 인증 코드 확인
        String existingCode = redisTemplate.opsForValue().get(email);
        if (existingCode != null) {
            // 기존 인증 코드가 유효한 경우 재전송
            emailService.sendEmailWithCode(email, "이메일 인증 코드", existingCode);
            return ResponseEntity.ok(Map.of("message", "기존 이메일 인증 코드를 다시 발송했습니다."));
        }

        // 새로운 6자리 인증 코드 생성
        String newCode = String.format("%06d", new Random().nextInt(1000000));

        // Redis에 인증 코드 저장 (10분 TTL)
        redisTemplate.opsForValue().set(email, newCode, VERIFICATION_CODE_TTL, TimeUnit.MINUTES);

        // 이메일로 인증 코드 전송
        emailService.sendEmailWithCode(email, "이메일 인증 코드", newCode);
        return ResponseEntity.ok(Map.of("message", "새로운 이메일 인증 코드를 발송했습니다."));
    }

    /**
     * 인증 코드 검증
     */
    @PostMapping("/verify-code")
    public ResponseEntity<?> verifyCode(@RequestBody VerifyCodeRequestDTO requestDTO) {
        System.out.println("verifyCode 엔드포인트 호출됨: 이메일=" + requestDTO.getEmail() + ", 토큰=" + requestDTO.getToken());

        if (requestDTO.getEmail() == null || requestDTO.getEmail().isEmpty()) {
            return ResponseEntity.badRequest().body("이메일을 입력해 주세요.");
        }

        if (requestDTO.getToken() == null || requestDTO.getToken().isEmpty()) {
            return ResponseEntity.badRequest().body("코드를 입력해 주세요.");
        }

        // Redis에서 인증 코드 조회
        String savedCode = emailVerificationService.getVerificationCode(requestDTO.getEmail());
        if (savedCode == null) {
            return ResponseEntity.badRequest().body("인증 코드가 만료되었거나 잘못된 요청입니다.");
        }

        if (!savedCode.equals(requestDTO.getToken())) {
            return ResponseEntity.badRequest().body("인증 코드가 일치하지 않습니다.");
        }

        // 인증 성공 처리 (Redis에서 인증 코드 삭제)
        emailVerificationService.deleteVerificationCode(requestDTO.getEmail());

        return ResponseEntity.ok(Map.of("message", "이메일 인증이 완료되었습니다."));
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
public ResponseEntity<?> getProfile(@AuthenticationPrincipal Object principal) {
    String username = null;

    if (principal instanceof UserDetails) {
        // 일반 로그인 사용자
        username = ((UserDetails) principal).getUsername();
    } else if (principal instanceof OAuth2User) {
        // OAuth2 사용자 (구글 로그인)
        OAuth2User oAuth2User = (OAuth2User) principal;
        String email = oAuth2User.getAttribute("email");

        // 이메일로 사용자 정보 조회
        username = userService.getUsernameByEmail(email); 
    }

    if (username == null) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("사용자를 찾을 수 없습니다.");
    }

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

    @GetMapping("/getUsernameByEmail")
    public ResponseEntity<?> getUsernameByEmail(@RequestParam String email) {
        return userRepository.findByEmail(email)
                .map(user -> ResponseEntity.ok(Collections.singletonMap("username", user.getUsername())))
                .orElse(ResponseEntity.notFound().build());
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


