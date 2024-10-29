package com.example.demo.service;

import java.util.Date;

import javax.crypto.SecretKey;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;

@Component
public class JwtTokenProvider {
    @Value("${jwt.secret}")
    private SecretKey secretKey;  // JWT 서명에 사용할 비밀 키
    private final long validityInMilliseconds = 3600000; // 1시간

    // JWT 토큰 생성
    public String createToken(String username) {
        Claims claims = Jwts.claims().setSubject(username);  // 주체로 username 설정
        Date now = new Date();
        Date validity = new Date(now.getTime() + validityInMilliseconds);  // 만료 시간 설정

        return Jwts.builder()
            .setClaims(claims)
            .setIssuedAt(now)  // 토큰 발행 시간
            .setExpiration(validity)  // 토큰 만료 시간
            .signWith(secretKey, SignatureAlgorithm.HS256)  // SecretKey를 직접 사용
            .compact();
    }
}