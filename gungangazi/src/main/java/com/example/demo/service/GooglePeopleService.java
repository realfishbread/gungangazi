package com.example.demo.service;

import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

@Service
public class GooglePeopleService {

    private static final Logger logger = LoggerFactory.getLogger(GooglePeopleService.class);
    private final WebClient webClient;

    @Autowired
    public GooglePeopleService(WebClient.Builder webClientBuilder) {
        this.webClient = webClientBuilder.baseUrl("https://people.googleapis.com").build();
    }

    /**
     * Google People API를 호출하여 사용자 성별 정보를 가져옵니다.
     */
    public Map<String, Object> fetchUserGender(String accessToken) {
        try {
            Map<String, Object> response = webClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .path("/v1/people/me")
                            .queryParam("personFields", "genders")
                            .build())
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + accessToken)
                    .retrieve()
                    .bodyToMono(Map.class)
                    .block();
    
            // 응답 데이터 확인
            logger.debug("Google People API 응답: {}", response);
            if (response != null && response.containsKey("genders")) {
                logger.debug("genders 필드 데이터: {}", response.get("genders"));
            }
            return response;
        } catch (Exception e) {
            logger.error("Google People API 호출 실패: {}", e.getMessage());
            return null;
        }
    }
    
    
}
