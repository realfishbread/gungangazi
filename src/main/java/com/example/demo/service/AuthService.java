package com.example.demo.service;
import java.time.LocalDateTime;
import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.entity.EmailToken;
import com.example.demo.repository.userHealth.EmailTokenRepository;

import jakarta.transaction.Transactional;

@Service
public class AuthService {

    private final EmailTokenRepository emailTokenRepository;



    @Autowired
    public AuthService(EmailTokenRepository emailTokenRepository) {
        this.emailTokenRepository = emailTokenRepository;
    }

    @Transactional
    public String sendVerificationCode(String email) {
        // 이메일로 기존 데이터 검색
        EmailToken existingToken = emailTokenRepository.findByEmail(email);

        // 기존 코드가 존재하고 유효 기간이 남아 있는 경우, 기존 코드 반환
        if (existingToken != null && existingToken.getExpiration_time().isAfter(LocalDateTime.now())) {
            return existingToken.getToken();
        }

        // 새 6자리 코드 생성
        String newCode = String.format("%06d", new Random().nextInt(1000000));
        LocalDateTime expirationTime = LocalDateTime.now().plusMinutes(10);

        EmailToken emailToken;

        if (existingToken != null) {
            // 기존 데이터가 있으면 업데이트
            existingToken.setToken(newCode);
            existingToken.setExpiration_time(expirationTime);
            emailToken = existingToken;
        } else {
            // 기존 데이터가 없으면 새 객체 생성
            emailToken = new EmailToken(email, expirationTime, newCode, false);
        }

        // 데이터 저장
        emailTokenRepository.save(emailToken);

        return newCode; // 새 코드 반환
    }




    public boolean verify(String email, String token) {
        EmailToken emailToken = emailTokenRepository.findByEmail(email);
    
        if (emailToken == null || !emailToken.getToken().equals(token)) {
            return false;
        }
    
        if (LocalDateTime.now().isAfter(emailToken.getExpiration_time())) {
            return false;
        }
    
        emailToken.setEmail_verified(true);
        emailTokenRepository.save(emailToken);
        return true;
    }
    

    private String generateVerificationCode() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(999999));
    }
}


