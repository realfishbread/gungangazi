package com.example.demo.controller;

import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.WebClient;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.GooglePeopleService;
import com.example.demo.service.JwtTokenProvider;

import reactor.core.publisher.Mono;


@Transactional
@RestController
@RequestMapping
public class GoogleAuthController {

    private static final Logger logger = LoggerFactory.getLogger(GoogleAuthController.class);

    @Value("${spring.security.oauth2.client.registration.google.client-id}")
    private String googleClientId;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
private GooglePeopleService googlePeopleService;
@PostMapping("/api/auth/google-login")
public ResponseEntity<?> googleLoginWithAccessToken(
        @RequestBody Map<String, String> request,
        @RequestHeader(value = "Authorization", required = false) String authorizationHeader) {

    final String accessToken;
    if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
        accessToken = authorizationHeader.substring(7);
    } else {
        accessToken = request.get("accessToken");
    }

    if (accessToken == null || accessToken.isEmpty()) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Access Token이 필요합니다.");
    }

    try {
        // Google API를 이용하여 사용자 정보 가져오기
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

       // Google People API로 성별 정보 가져오기
Map<String, Object> profile = googlePeopleService.fetchUserGender(accessToken);
String gender = "비공개"; // 기본값 설정

if (profile != null && profile.containsKey("genders")) {
    try {
        List<Map<String, Object>> genders = (List<Map<String, Object>>) profile.get("genders");
        if (!genders.isEmpty()) {
            Map<String, Object> genderInfo = genders.get(0);
            String genderFormatted = (String) genderInfo.get("formattedValue");
            String genderValue = (String) genderInfo.get("value");

            logger.info("Google People API 성별 응답 - formattedValue: {}, value: {}", genderFormatted, genderValue);

            if (genderFormatted != null && !genderFormatted.isEmpty()) {
                if ("여성".equalsIgnoreCase(genderFormatted) || "female".equalsIgnoreCase(genderFormatted)) {
                    gender = "여성";
                } else if ("남성".equalsIgnoreCase(genderFormatted) || "male".equalsIgnoreCase(genderFormatted)) {
                    gender = "남성";
                } else {
                    gender = "비공개"; 
                }
            } else if (genderValue != null) {
                switch (genderValue.toLowerCase()) {
                    case "female":
                        gender = "여성";
                        break;
                    case "male":
                        gender = "남성";
                        break;
                    default:
                        gender = "비공개";
                        break;
                }
            }
        }
    } catch (Exception e) {
        logger.error("성별 데이터 처리 중 오류 발생: {}", e.getMessage());
    }
}

logger.info("최종 변환된 성별: {}", gender);

// 최종 성별 값 출력
logger.info("변환된 최종 성별 값: {}", gender);


// 최종 성별 값 로그 출력
logger.info("성별 저장 값: {}", gender);


// 최종 성별 값 로그 출력


        // 사용자 검색
        Optional<User> optionalUser = userRepository.findByEmail(email);
        boolean existingUser = optionalUser.isPresent();

        User user;
        if (existingUser) {
            user = optionalUser.get();
        
            // Google 계정 연동 여부 설정
            user.setIs_google_user(true);
        
            // 기존 값이 없을 경우에만 업데이트
            if (user.getGender() == null || user.getGender().isEmpty()) {
                user.setGender(gender);
            }
            if (user.getRealname() == null || user.getRealname().isEmpty()) {
                user.setRealname(realname);
            }
        
            // 변경된 값 저장
            userRepository.save(user); // 저장 명시적으로 호출
        
            logger.info("기존 사용자를 Google 계정으로 업데이트: {}", email);
        } else {
            // 신규 사용자 등록
            user = new User();
            user.setEmail(email);
            user.setRealname(realname);
            user.setGender(gender);
            user.setIs_google_user(true);
            user.setUsername(email);
        
            userRepository.save(user);
            logger.info("새로운 Google 계정으로 사용자 등록: {}", email);
        }
        

        // JWT 토큰 발급
        String token = jwtTokenProvider.createToken(email);

        // 응답 반환
        return ResponseEntity.ok(Map.of(
            "message", "Google 로그인 성공",
            "token", token,
            "email", email,
            "username", existingUser ? user.getUsername() : email,  // ✅ 기존 유저는 username 변경 ❌
            "realname", user.getRealname(),
            "gender", user.getGender(), // 최신 user.getGender() 값 사용
            "existingUser", existingUser
        ));
    } catch (Exception e) {
        logger.error("Google 로그인 실패: {}", e.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Google 로그인 실패: " + e.getMessage());
    }
}
}
