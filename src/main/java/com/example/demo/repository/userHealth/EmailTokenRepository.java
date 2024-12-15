package com.example.demo.repository.userHealth;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.demo.entity.EmailToken;

public interface EmailTokenRepository extends JpaRepository<EmailToken, Long> {
    // 토큰 값으로 EmailToken 검색
    Optional<EmailToken> findByToken(String token);
}
