package com.example.demo.service;
import java.util.Random;

import org.springframework.stereotype.Service;

@Service
public class AuthService {
    private final EmailVerificationService emailVerificationService;
    private final EmailService emailService;

    public AuthService(EmailVerificationService emailVerificationService, EmailService emailService) {
        this.emailVerificationService = emailVerificationService;
        this.emailService = emailService;
    }
    

    public String generateVerificationCode() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(1000000)); // 6자리 랜덤 숫자
    }

    public void sendVerificationCode(String email) {
        String code = generateVerificationCode(); // 랜덤 6자리 코드 생성
        emailVerificationService.saveVerificationCode(email, code); // Redis에 저장
        emailService.sendEmailWithCode(email, "이메일 인증 코드", code); // 이메일 전송
    }
}



