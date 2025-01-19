package com.example.demo.controller;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.JwtTokenProvider;

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

                String username = payload.getSubject();
                String email = payload.getEmail();
                String realname = (String) payload.get("name");
                String gender = (String) payload.get("gender");

                logger.info("Google 로그인 성공: userId={}, email={}, name={}", username, email, realname);

                Optional<User> optionalUser = userRepository.findByEmail(email);
                if (optionalUser.isEmpty()) {
                    User user = new User(username, email, realname, gender, true);
                    userRepository.save(user);
                } else {
                    User user = optionalUser.get();
                    if (!user.isGoogleUser()) {
                        return ResponseEntity.status(HttpStatus.CONFLICT)
                                .body("이미 일반 회원가입으로 등록된 이메일입니다.");
                    }
                }

                String token = jwtTokenProvider.createToken(username);
                return ResponseEntity.ok(Map.of(
                    "token", token,
                    "message", "Google 로그인 성공",
                    "email", email,
                    "name", realname
                ));
            } else {
                logger.error("Invalid ID Token");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid ID Token");
            }
        } catch (Exception e) {
            logger.error("Google 로그인 실패", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Google 로그인 실패: " + e.getMessage());
        }
    }
}
