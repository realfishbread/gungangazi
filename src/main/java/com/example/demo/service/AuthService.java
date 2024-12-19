package com.example.demo.service;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.DTO.UserDTO;
import com.example.demo.entity.EmailToken;
import com.example.demo.repository.userHealth.EmailTokenRepository;

@Service
public class AuthService {

    private final EmailTokenRepository emailTokenRepository;
    private final UserService userService;

    private final HashSet<String> verifiedEmails = new HashSet<>(); // 검증된 이메일 목록

    @Autowired
    public AuthService(EmailTokenRepository emailTokenRepository, UserService userService) {
        this.emailTokenRepository = emailTokenRepository;
        this.userService = userService;
    }

    // Step 1: 인증 코드 전송
    public void sendVerificationCode(String email) {
        // 6자리 인증 번호 생성
        String verificationCode = generateVerificationCode();
        LocalDateTime expirationTime = LocalDateTime.now().plusMinutes(10); // 10분 유효

        // 기존 인증 번호 삭제
        emailTokenRepository.deleteByEmail(email);

        // 새 인증 번호 저장
        emailTokenRepository.save(new EmailToken(verificationCode, email, expirationTime));
    }

    // Step 2: 인증 코드 검증
    public boolean verifyCode(String email, String code) {
        EmailToken token = emailTokenRepository.findByEmail(email);

        if (token != null && token.getToken().equals(code) && LocalDateTime.now().isBefore(token.getExpiration_time())) {
            // 인증 성공 → 이메일 상태 저장
            verifiedEmails.add(email);
            emailTokenRepository.delete(token); // 토큰 삭제
            return true;
        }
        return false;
    }

    // Step 3: 최종 사용자 저장
    public boolean registerUserIfVerified(String email, UserDTO userDTO) {
        if (verifiedEmails.contains(email)) {
            // 이메일 인증된 경우 사용자 저장
            userService.registerUser(userDTO);
            verifiedEmails.remove(email); // 인증 완료 후 상태 제거
            return true;
        }
        return false; // 인증되지 않은 이메일
    }

    private String generateVerificationCode() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(999999));
    }
}


