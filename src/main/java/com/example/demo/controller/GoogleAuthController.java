package com.example.demo.controller;

import java.util.Collections;
import java.util.Map;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.JwtTokenProvider;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;

@RestController
@RequestMapping("/api/auth")
public class GoogleAuthController {

    private static final Logger logger = LoggerFactory.getLogger(GoogleAuthController.class);

    @Value("${spring.security.oauth2.client.registration.google.client-id}")
    private String googleClientId;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @PostMapping("/google-login")
    public ResponseEntity<?> googleLogin(@RequestBody Map<String, String> request) {
        String idToken = request.get("idToken");
        String accessToken = request.get("accessToken"); // 추가된 Access Token
    
        if (idToken == null || idToken.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("ID Token이 필요합니다.");
        }
    
        if (accessToken == null || accessToken.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Access Token이 필요합니다.");
        }
    
        try {
            // ID Token 검증
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(), new GsonFactory())
                    .setAudience(Collections.singletonList(googleClientId))
                    .build();
    
            GoogleIdToken googleIdToken = verifier.verify(idToken);
            if (googleIdToken != null) {
                GoogleIdToken.Payload payload = googleIdToken.getPayload();
                String email = payload.getEmail();
                String realname = (String) payload.get("name");
    
                // Access Token 검증 (필요 시)
                if (!validateAccessToken(accessToken)) {
                    return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("유효하지 않은 Access Token입니다.");
                }
    
                // 사용자 처리 로직 (기존 로직과 동일)
                // ...
    
                return ResponseEntity.ok(Map.of(
                    "message", "Google 로그인 성공",
                    "token", jwtTokenProvider.createToken(email),
                    "email", email,
                    "name", realname
                ));
            } else {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("유효하지 않은 ID Token입니다.");
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Google 로그인 실패: " + e.getMessage());
        }
    }
    
    // Access Token 검증 메서드 예시 (Google API 호출)
    private boolean validateAccessToken(String accessToken) {
        // Google Access Token 검증 로직 추가 (예: HTTP 요청으로 검증)
        return true; // 실제 검증 로직 구현 필요
    }
    

        @PostMapping("/link-google")
        public ResponseEntity<?> linkGoogleAccount(@RequestBody Map<String, String> request) {
            String idToken = request.get("idToken");
            String email = request.get("email"); // 회원가입 시 사용한 이메일
        
            if (idToken == null || idToken.isEmpty()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("ID Token이 필요합니다.");
            }
        
            try {
                GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                        new NetHttpTransport(), new GsonFactory())
                        .setAudience(Collections.singletonList(googleClientId))
                        .build();
        
                GoogleIdToken googleIdToken = verifier.verify(idToken);
                if (googleIdToken != null) {
                    GoogleIdToken.Payload payload = googleIdToken.getPayload();
                    String googleEmail = payload.getEmail();
        
                    // 이메일로 사용자 찾기
                    Optional<User> optionalUser = userRepository.findByEmail(email);
                    if (optionalUser.isEmpty()) {
                        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("사용자를 찾을 수 없습니다.");
                    }
        
                    User user = optionalUser.get();
        
                    // 구글 계정 이메일이 일치하지 않으면 오류 반환
                    if (!email.equals(googleEmail)) {
                        return ResponseEntity.status(HttpStatus.CONFLICT)
                                .body("구글 계정 이메일이 기존 계정 이메일과 일치하지 않습니다.");
                    }
        
                    // 구글 계정 연동
                    user.setIsGoogleUser(true);
                    userRepository.save(user);
        
                    return ResponseEntity.ok("구글 계정 연동 성공");
                } else {
                    return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("유효하지 않은 ID Token입니다.");
                }
            } catch (Exception e) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("구글 계정 연동 실패: " + e.getMessage());
            }
        }
        

}
