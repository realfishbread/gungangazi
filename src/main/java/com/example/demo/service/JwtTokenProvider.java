package com.example.demo.service;
import java.util.Date;

import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;

@Component
public class JwtTokenProvider {

    @Value("${jwt.secret}")
    private String secretKey; // String으로 주입받음
    private final long validityInMilliseconds = 3600000; // 1시간

    // JWT 토큰 생성
    public String createToken(String username) {
        Claims claims = Jwts.claims().setSubject(username);
        Date now = new Date();
        Date validity = new Date(now.getTime() + validityInMilliseconds);

        return Jwts.builder()
                .setClaims(claims)
                .setIssuedAt(now)
                .setExpiration(validity)
                .signWith(getSecretKey(), SignatureAlgorithm.HS256) // SecretKey를 사용
                .compact();
    }

    // 비밀 키를 SecretKey로 변환하는 메서드
    private SecretKey getSecretKey() {
        return new SecretKeySpec(secretKey.getBytes(), "HmacSHA256");
    }
}