package com.example.demo.service;

import java.util.concurrent.TimeUnit;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

@Service
public class EmailVerificationService {

    @Autowired
    private StringRedisTemplate redisTemplate;

    // 인증번호 저장
    public void saveVerificationCode(String email, String code) {
        redisTemplate.opsForValue().set(email, code, 10, TimeUnit.MINUTES); // 10분 TTL 설정
    }

    // 인증번호 조회
    public String getVerificationCode(String email) {
        return redisTemplate.opsForValue().get(email);
    }

    // 인증번호 삭제
    public void deleteVerificationCode(String email) {
        redisTemplate.delete(email);
    }
}
