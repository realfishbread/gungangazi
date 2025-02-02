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
import org.springframework.web.bind.annotation.RequestHeader;
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

import reactor.core.publisher.Mono;

@CrossOrigin(origins = "*", allowedHeaders = "*")
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
public ResponseEntity<?> googleLoginWithAccessToken(
        @RequestBody Map<String, String> request,
        @RequestHeader(value = "Authorization", required = false) String authorizationHeader) {

            final String accessToken; // final로 선언
    if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
        accessToken = authorizationHeader.substring(7); // 헤더에서 토큰 추출
    } else {
        accessToken = request.get("accessToken"); // 본문에서 토큰 추출
    }

    if (accessToken == null || accessToken.isEmpty()) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Access Token이 필요합니다.");
    }

    try {
        // Access Token 검증 및 사용자 정보 가져오기
        WebClient webClient = WebClient.builder()
                .baseUrl("https://www.googleapis.com")
                .build();

                Map<String, Object> response = webClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/oauth2/v3/userinfo")
                            .queryParam("access_token", accessToken)
                            .build())
                    .retrieve()
                    .bodyToMono(Map.class)
                    .onErrorResume(e -> {
                        logger.error("Google API 호출 실패: {}", e.getMessage());
                        return Mono.empty();
                    })
                    .block();
        if (response == null || !response.containsKey("email")) {
            logger.warn("Access Token 검증 실패: {}", accessToken);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("유효하지 않은 Access Token입니다.");
        }

        // 사용자 정보 추출
        String email = (String) response.get("email");
        String realname = (String) response.getOrDefault("name", "unknown");
        String gender = (String) response.getOrDefault("gender", "unknown");

        // 사용자 검색
        Optional<User> optionalUser = userRepository.findByEmail(email);
        boolean existingUser = optionalUser.isPresent();

        User user;
        if (existingUser) {
            // 기존 사용자 확인
            user = optionalUser.get();
            if (!user.getIs_google_user()) {
                return ResponseEntity.status(HttpStatus.CONFLICT)
                        .body("이미 일반 회원가입으로 등록된 이메일입니다.");
            }
        } else {
            // 신규 사용자 등록
            user = new User();
            user.setEmail(email);
            user.setRealname(realname);
            user.setGender(gender);
            user.setIs_google_user(true);
            userRepository.save(user);
            logger.info("새로운 구글 계정으로 사용자 등록: {}", email);
        }

        // JWT 토큰 발급
        String token = jwtTokenProvider.createToken(email);

        // 응답 반환
        return ResponseEntity.ok(Map.of(
                "message", "Google 로그인 성공",
                "token", token,
                "email", email,
                "realname", realname,
                "existingUser", existingUser
        ));
    } catch (Exception e) {
        logger.error("Google 로그인 실패: {}", e.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Google 로그인 실패: " + e.getMessage());
    }
}
    

// Access Token 검증
private boolean validateAccessToken(String accessToken) {
    try {
        WebClient webClient = WebClient.builder()
                .baseUrl("https://www.googleapis.com")
                .build();

        Map<String, Object> response = webClient.get()
                .uri("/oauth2/v1/userinfo?alt=json&access_token=" + accessToken)
                .retrieve()
                .bodyToMono(Map.class)
                .block();

        if (response != null && response.containsKey("email")) {
            logger.info("Access Token 검증 성공: {}", response);
            return true;
        } else {
            logger.warn("Access Token 검증 실패: 응답 데이터 없음");
            return false;
        }
    } catch (Exception e) {
        logger.error("Access Token 검증 중 오류 발생: {}", e.getMessage());
        return false;
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
