package com.example.demo.service;

import java.util.Date;

import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;

@Component
public class JwtTokenProvider {
    // JWT 서명에 사용할 비밀 키를 문자열로 주입받습니다.
    @Value("${jwt.secret}")
    private String secretKeyString;  // 문자열로 주입받은 비밀 키

    private SecretKey secretKey;  // JWT 서명에 사용할 비밀 키// JWT 서명에 사용할 비밀 키
    private final long validityInMilliseconds = 3600000; // 1시간


    public JwtTokenProvider() {
        // 비밀 키 문자열을 사용하여 SecretKey 객체를 생성합니다.
        this.secretKey = Keys.hmacShaKeyFor(secretKeyString.getBytes());
    }
    
    // JWT 토큰 생성
    public String createToken(String username) {
        Claims claims = Jwts.claims().setSubject(username);  // 주체로 username 설정
        Date now = new Date();
        Date validity = new Date(now.getTime() + validityInMilliseconds);  // 만료 시간 설정

        return Jwts.builder()
            .setClaims(claims)
            .setIssuedAt(now)  // 토큰 발행 시간
            .setExpiration(validity)  // 토큰 만료 시간
            .signWith(Keys.hmacShaKeyFor(secretKey.getBytes()), SignatureAlgorithm.HS256)
  // 서명 알고리즘과 비밀 키
            .compact();
    }
}