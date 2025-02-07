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
        // Access Token 검증 및 기본 사용자 정보 가져오기
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

        // 추가 사용자 정보 (People API 호출)
        Map<String, Object> profile = googlePeopleService.fetchUserGender(accessToken);
        String gender = null;

        // 성별 데이터 추출
        if (profile != null && profile.containsKey("genders")) {
            try {
                List<Map<String, Object>> genders = (List<Map<String, Object>>) profile.get("genders");
                if (!genders.isEmpty()) {
                    String genderValue = (String) genders.get(0).get("value");
                    if ("female".equalsIgnoreCase(genderValue)) {
                        gender = "여성";
                    } else if ("male".equalsIgnoreCase(genderValue)) {
                        gender = "남성";
                    } else {
                        gender = "비공개"; // 알 수 없는 값에 대해 기본값 설정
                    }
                }
            } catch (Exception e) {
                logger.error("성별 데이터 처리 중 오류 발생: {}", e.getMessage());
            }
        }
        

        // 성별 정보가 없는 경우 기본값 설정
        if (gender == null || gender.isEmpty()) {
            gender = "비공개"; // 기본값을 '비공개'로 설정
        }

        // 사용자 검색
        Optional<User> optionalUser = userRepository.findByEmail(email);
        boolean existingUser = optionalUser.isPresent();

        User user;
        if (existingUser) {
            user = optionalUser.get();
            
            // Google 계정 연동 여부 업데이트 (필요한 경우만)
            if (user.getIs_google_user() == null || !user.getIs_google_user()) {
                user.setIs_google_user(true);
            }
        
            // 성별 정보 업데이트 (gender가 비어 있으면만)
            if ((user.getGender() == null || user.getGender().isEmpty()) && gender != null) {
                user.setGender(gender);
            }
        
            // 이름 업데이트 (realname이 비어 있으면만)
            if ((user.getRealname() == null || user.getRealname().isEmpty()) && realname != null) {
                user.setRealname(realname);
            }
        
            // 기존 사용자 정보 업데이트
            userRepository.save(user);
            logger.info("기존 사용자를 Google 계정으로 업데이트: {}", email);
        } else {
            // 신규 사용자 등록
            user = new User();
            user.setEmail(email);
            user.setRealname(realname);
            user.setGender(gender);
            user.setIs_google_user(true);
            user.setUsername(email);  // 기존 username과 충돌되지 않도록 설정
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
                "realname", realname,
                "gender", gender,
                "existingUser", existingUser
        ));
    } catch (Exception e) {
        logger.error("Google 로그인 실패: {}", e.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Google 로그인 실패: " + e.getMessage());
    }
}

public void fetchAndSaveUserInfo(String accessToken, User user) {
    Map<String, Object> profile = googlePeopleService.fetchUserGender(accessToken);
    if (profile != null) {
        logger.debug("Google People API 응답: {}", profile);

        // 성별 처리
        String gender = "기타"; // 기본값 설정
        if (profile.containsKey("genders")) {
            try {
                // "genders" 필드를 List<Map<String, Object>>로 처리
                List<?> genders = (List<?>) profile.get("genders");
                if (genders != null && !genders.isEmpty() && genders.get(0) instanceof Map) {
                    Map<?, ?> genderMap = (Map<?, ?>) genders.get(0);
                    Object genderValueObj = genderMap.get("value");
                    if (genderValueObj instanceof String) {
                        String genderValue = (String) genderValueObj;
                        if ("female".equalsIgnoreCase(genderValue)) {
                            gender = "여성";
                        } else if ("male".equalsIgnoreCase(genderValue)) {
                            gender = "남성";
                        }
                    }
                }
            } catch (ClassCastException e) {
                logger.error("genders 데이터 타입 변환 실패: {}", e.getMessage());
            }
        } else {
            logger.warn("genders 정보가 응답에 포함되지 않았습니다.");
        }
    }
}
}