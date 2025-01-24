package com.example.demo.controller;

import java.util.Collections;
import java.util.Map;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory; // URL 클래스
import org.springframework.beans.factory.annotation.Autowired; // IOException 클래스
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus; // WebClient
import org.springframework.http.ResponseEntity; // 예외 처리용
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

        // 구글 ID 토큰 검증 로직은 동일
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
                user.setIsGoogleUser(true); // 구글 계정 여부 설정
                userRepository.save(user);

                logger.info("새로운 구글 계정으로 사용자 등록: {}", email);
            } else {
                // 기존 사용자와 이메일이 동일한 경우 처리
                User user = optionalUser.get();
                if (!user.getIsGoogleUser()) {
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
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Google 로그인 실패: " + e.getMessage());
    }
}

    
    // Access Token 검증 메서드 예시 (Google API 호출)
private boolean validateAccessToken(String accessToken) {
    String url = "https://www.googleapis.com/oauth2/v1/tokeninfo?access_token=" + accessToken;

    try {
        // WebClient를 사용하여 Google API에 요청
        WebClient webClient = WebClient.builder()
            .baseUrl("https://www.googleapis.com")
            .build();

        // 비동기로 요청을 보내고 결과를 기다림
        Map<String, Object> response = webClient.get()
            .uri(uriBuilder -> uriBuilder
                .path("/oauth2/v1/tokeninfo")
                .queryParam("access_token", accessToken)
                .build())
            .retrieve()
            .bodyToMono(Map.class)
            .block(); // 비동기 작업을 동기적으로 변환

        if (response != null) {
            // 응답 데이터 출력 (JSON 형태)
            System.out.println("Google Token Info: " + response);
            return true; // 토큰이 유효한 경우
        } else {
            System.out.println("Invalid Access Token. No response from Google API.");
            return false; // 응답이 없는 경우
        }
    } catch (Exception e) {
        // 요청 중 예외 처리
        System.err.println("Access Token 검증 실패: " + e.getMessage());
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
            user.setIsGoogleUser(true);
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
