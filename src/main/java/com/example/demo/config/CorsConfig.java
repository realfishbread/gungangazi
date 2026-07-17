package com.example.demo.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;


@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**") 
                .allowedOrigins(
                        "https://gunganghazi.site", 
                        "http://localhost:8080",  
                        "http://localhost:3000"   
                )
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD") // 허용할 HTTP 메소드
                .allowedHeaders("Authorization", "Content-Type", "X-Requested-With", "Accept", "*") // 허용할 헤더
                .allowCredentials(true); // 인증 정보 허용 (선택 사항)
    }
}

