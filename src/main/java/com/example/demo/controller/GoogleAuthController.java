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
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.WebClient;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.JwtTokenProvider;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;

@CrossOrigin
@Transactional
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
        String accessToken = request.get("accessToken");

        if (idToken == null || idToken.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("ID Token이 필요합니다.");
        }

        if (accessToken == null || accessToken.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Access Token이 필요합니다.");
        }

        try {
            // Access Token 검증
            if (!validateAccessToken(accessToken)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("유효하지 않은 Access Token입니다.");
            }

            // 구글 ID 토큰 검증 로직
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(), new GsonFactory())
                    .setAudience(Collections.singletonList(googleClientId))
                    .build();

            GoogleIdToken googleIdToken = verifier.verify(idToken);
            if (googleIdToken != null) {
                GoogleIdToken.Payload payload = googleIdToken.getPayload();

                String email = payload.getEmail(); // 이메일 기준으로 사용자를 찾음
                String realname = (String) payload.get("name");
                String gender = (String) payload.get("gender");

                // 이메일로 사용자 검색
                Optional<User> optionalUser = userRepository.findByEmail(email);

                if (optionalUser.isEmpty()) {
                    // 구글 계정이 처음인 경우 새로 저장
                    User user = new User();
                    user.setEmail(email);
                    user.setRealname(realname);
                    user.setGender(gender);
                    user.setIs_google_user(true); // 구글 계정 여부 설정
                    userRepository.save(user);

                    logger.info("새로운 구글 계정으로 사용자 등록: {}", email);
                } else {
                    // 기존 사용자와 이메일이 동일한 경우 처리
                    User user = optionalUser.get();
                    if (!user.getIs_google_user()) {
                        return ResponseEntity.status(HttpStatus.CONFLICT)
                                .body("이미 일반 회원가입으로 등록된 이메일입니다.");
                    }
                }

                // JWT 발급 및 응답
                String token = jwtTokenProvider.createToken(email);
                return ResponseEntity.ok(Map.of(
                        "message", "Google 로그인 성공",
                        "token", token,
                        "email", email,
                        "realname", realname
                ));
            } else {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("유효하지 않은 ID Token입니다.");
            }
        } catch (Exception e) {
            logger.error("Google 로그인 실패: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Google 로그인 실패: " + e.getMessage());
        }
    }

    // Access Token 검증 메서드
    private boolean validateAccessToken(String accessToken) {
        try {
            // WebClient를 사용하여 Google API 호출
            WebClient webClient = WebClient.builder()
                    .baseUrl("https://www.googleapis.com")
                    .build();

            // Google API 호출하여 Access Token 검증
            Map<String, Object> response = webClient.get()
            .uri("/oauth2/v1/userinfo?alt=json&access_token=" + accessToken)
            .retrieve()
            .bodyToMono(Map.class)
            .block();
         // 동기적으로 결과 대기

            if (response != null && response.containsKey("email")) {
                logger.info("Google Access Token 검증 성공: {}", response);
                return true; // Access Token 유효
            } else {
                logger.warn("Access Token 검증 실패: 응답 데이터 없음");
                return false; // 응답 없음
            }
        } catch (Exception e) {
            logger.error("Access Token 검증 중 오류 발생: {}", e.getMessage());
            return false; // 검증 실패
        }
    }

    

@PostMapping("/link-google")
public ResponseEntity<?> linkGoogleAccount(@RequestBody Map<String, String> request) {
    String idToken = request.get("idToken");
    String email = request.get("email"); // 기존 회원가입 시 사용한 이메일

    if (idToken == null || idToken.isEmpty()) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("ID Token이 필요합니다.");
    }

    try {
        // Google ID Token 검증
        GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                new NetHttpTransport(), new GsonFactory())
                .setAudience(Collections.singletonList(googleClientId))
                .build();

        GoogleIdToken googleIdToken = verifier.verify(idToken);
        if (googleIdToken != null) {
            GoogleIdToken.Payload payload = googleIdToken.getPayload();
            String googleEmail = payload.getEmail();

            // 기존 사용자 계정 찾기
            Optional<User> optionalUser = userRepository.findByEmail(email);
            if (optionalUser.isEmpty()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("사용자를 찾을 수 없습니다.");
            }

            User user = optionalUser.get();

            // Google 계정 이메일이 기존 이메일과 다르면 오류 반환
            if (!googleEmail.equals(email)) {
                return ResponseEntity.status(HttpStatus.CONFLICT)
                        .body("Google 계정 이메일이 기존 계정 이메일과 일치하지 않습니다.");
            }

            // 기존 사용자 계정과 Google 계정을 연결
            user.setIs_google_user(true);
            userRepository.save(user);

            return ResponseEntity.ok(Map.of(
                "message", "Google 계정이 성공적으로 연결되었습니다."
            ));
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("유효하지 않은 ID Token입니다.");
        }
    } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Google 계정 연결 실패: " + e.getMessage());
    }
}

}
