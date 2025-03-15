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
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.WebClient;

import com.example.demo.entity.User;
import com.example.demo.repository.UserRepository;
import com.example.demo.service.JwtTokenProvider;


@Transactional
@RestController
@RequestMapping
public class GoogleAuthController {

    private static final Logger logger = LoggerFactory.getLogger(GoogleAuthController.class);

    @Value("${spring.security.oauth2.client.registration.google.client-id}")
    private String googleWebClientId;

    @Value("${spring.security.oauth2.client.registration.google.client-secret}")
    private String googleWebClientSecret;

    @Value("${google.client.android.client-id}") // ✅ 안드로이드용 추가
    private String googleAndroidClientId;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private WebClient.Builder webClientBuilder; // WebClient 사용

    @PostMapping("/api/auth/google-login")
public ResponseEntity<?> googleLogin(@RequestBody Map<String, String> request) {
    String authCode = request.get("authCode");
    String clientType = request.get("clientType"); // 📌 클라이언트 타입 추가 (android/web)

    if (authCode == null || authCode.isEmpty()) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Auth Code가 필요합니다.");
    }

    try {
        // 📌 1️⃣ 클라이언트 타입에 따라 다른 Client ID 사용
        String clientId;
        String clientSecret;
        
        if ("android".equalsIgnoreCase(clientType)) {
            clientId = googleAndroidClientId;  // ✅ 안드로이드 클라이언트 ID
            clientSecret = ""; // 안드로이드는 secret 필요 없음
        } else {
            clientId = googleWebClientId;  // ✅ 웹 클라이언트 ID
            clientSecret = googleWebClientSecret;
        }

        // 📌 2️⃣ Auth Code를 Google OAuth 서버에 보내고 Access Token 교환
        Map<String, Object> tokenResponse = exchangeAuthCodeForToken(authCode, clientId, clientSecret);
        if (tokenResponse == null || !tokenResponse.containsKey("access_token")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Auth Code 검증 실패");
        }

        String accessToken = (String) tokenResponse.get("access_token");


        // 📌 3️⃣ Access Token을 사용하여 사용자 정보 가져오기
        Map<String, Object> userInfo = fetchUserProfile(accessToken);
        if (userInfo == null || !userInfo.containsKey("email")) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("유효하지 않은 Access Token입니다.");
        }

        String email = (String) userInfo.get("email");
        String realname = (String) userInfo.getOrDefault("name", "unknown");

        // 📌 4️⃣ Google People API로 성별 정보 가져오기
        String gender = "비공개"; // 기본값
        Map<String, Object> profile = fetchUserProfile(accessToken);

        if (profile != null && profile.containsKey("genders")) {
            try {
                List<Map<String, Object>> genders = (List<Map<String, Object>>) profile.get("genders");
                if (!genders.isEmpty()) {
                    Map<String, Object> genderInfo = genders.get(0);
                    String genderFormatted = (String) genderInfo.get("formattedValue");

                    if ("여성".equalsIgnoreCase(genderFormatted) || "female".equalsIgnoreCase(genderFormatted)) {
                        gender = "여성";
                    } else if ("남성".equalsIgnoreCase(genderFormatted) || "male".equalsIgnoreCase(genderFormatted)) {
                        gender = "남성";
                    }
                }
            } catch (Exception e) {
                logger.error("성별 데이터 처리 중 오류 발생: {}", e.getMessage());
            }
        }

        // 📌 5️⃣ DB에서 유저 조회 또는 신규 등록
        Optional<User> optionalUser = userRepository.findByEmail(email);
        boolean existingUser = optionalUser.isPresent();
        User user;

        if (existingUser) {
            user = optionalUser.get();
            user.setIs_google_user(true);
            if (user.getGender() == null || user.getGender().isEmpty()) {
                user.setGender(gender);
            }
            if (user.getRealname() == null || user.getRealname().isEmpty()) {
                user.setRealname(realname);
            }
            userRepository.save(user);
        } else {
            user = new User();
            user.setEmail(email);
            user.setRealname(realname);
            user.setGender(gender);
            user.setIs_google_user(true);
            user.setUsername(email);
            userRepository.save(user);
        }

        // 📌 6️⃣ JWT 토큰 발급
        String token = jwtTokenProvider.createToken(email);

        // 📌 7️⃣ 클라이언트에 응답 반환
        return ResponseEntity.ok(Map.of(
            "message", "Google 로그인 성공",
            "token", token,
            "email", email,
            "gender", user.getGender(),
            "username", existingUser ? user.getUsername() : email,
            "realname", user.getRealname(),
            "existingUser", existingUser
        ));
    } catch (Exception e) {
        logger.error("Google 로그인 실패: {}", e.getMessage());
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Google 로그인 실패: " + e.getMessage());
    }
}


private Map<String, Object> exchangeAuthCodeForToken(String authCode, String clientId, String clientSecret) {
    WebClient webClient = webClientBuilder.build();
    return webClient.post()
        .uri("https://oauth2.googleapis.com/token")
        .bodyValue(Map.of(
            "code", authCode,
            "client_id", clientId,
            "client_secret", clientSecret,  // ✅ 안드로이드는 secret 필요 없음
            "redirect_uri", "",  
            "grant_type", "authorization_code"
        ))
        .retrieve()
        .bodyToMono(Map.class)
        .block();
}



    /** 🟢 Access Token을 이용해 사용자 정보를 가져오는 함수 */
    /** ✅ Google People API를 사용하여 성별 정보 가져오기 */
private Map<String, Object> fetchUserProfile(String accessToken) {
    WebClient webClient = webClientBuilder.build();
    return webClient.get()
        .uri("https://people.googleapis.com/v1/people/me?personFields=genders,names")
        .header("Authorization", "Bearer " + accessToken)
        .retrieve()
        .bodyToMono(Map.class)
        .block();
}

}
