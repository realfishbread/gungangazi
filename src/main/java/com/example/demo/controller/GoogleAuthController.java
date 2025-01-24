package com.example.demo.controller;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection; // URL 클래스
import java.net.URL; // IOException 클래스
import java.nio.charset.StandardCharsets;
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
        // HTTP 요청 실행
        HttpURLConnection connection = (HttpURLConnection) new URL(url).openConnection();
        connection.setRequestMethod("GET");
        connection.setConnectTimeout(5000);
        connection.setReadTimeout(5000);

        int responseCode = connection.getResponseCode();

        if (responseCode == HttpURLConnection.HTTP_OK) {
            // 응답이 200이면 토큰이 유효
            try (InputStream is = connection.getInputStream();
                 InputStreamReader isr = new InputStreamReader(is, StandardCharsets.UTF_8);
                 BufferedReader br = new BufferedReader(isr)) {
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line);
                }

                // JSON 파싱으로 토큰 정보 확인 가능
                System.out.println("Google Token Info: " + response);
            }
            return true;
        } else {
            // 응답이 200이 아니면 토큰이 유효하지 않음
            System.out.println("Invalid Access Token. Response Code: " + responseCode);
            return false;
        }
    } catch (IOException e) {
        // 요청 중 오류 처리
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
