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
        // Redis에 키(email)와 값(code) 저장, TTL 10분 설정
        redisTemplate.opsForValue().set(email, code, 10, TimeUnit.MINUTES);
    }

    // 인증번호 조회
    public String getVerificationCode(String email) {
        // Redis에서 키(email)를 사용해 인증 코드 조회
        return redisTemplate.opsForValue().get(email);
    }

    // 인증번호 삭제
    public void deleteVerificationCode(String email) {
        // Redis에서 키(email)를 삭제
        redisTemplate.delete(email);
    }

    // 인증번호 검증
    public Boolean verifyEmailCode(String email, String code) {
        // 1. Redis에서 인증 코드를 조회
        String codeFoundByEmail = redisTemplate.opsForValue().get(email);
        System.out.println("Redis에서 조회된 코드: " + codeFoundByEmail); // 디버깅용 로그

        // 2. Redis에 저장된 코드가 없으면 false 반환
        if (codeFoundByEmail == null) {
            return false;
        }

        // 3. Redis에 저장된 코드와 입력된 코드가 일치하는지 비교
        return codeFoundByEmail.equals(code);
    }
}
