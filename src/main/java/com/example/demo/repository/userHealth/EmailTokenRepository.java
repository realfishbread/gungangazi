package com.example.demo.repository.userHealth;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.demo.entity.EmailToken;


@Repository
public interface EmailTokenRepository extends JpaRepository<EmailToken, Long> {
    void deleteByEmail(String email); // 삭제 메서드
    EmailToken findByEmail(String email); // 조회 메서드
    EmailToken findByToken(String token);
}
