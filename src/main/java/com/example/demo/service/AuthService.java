package com.example.demo.service;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.DTO.UserDTO;
import com.example.demo.entity.EmailToken;
import com.example.demo.entity.User;
import com.example.demo.repository.userHealth.EmailTokenRepository;

@Service
public class AuthService {

    private final EmailTokenRepository emailTokenRepository;
    private final EmailService emailService;
    private final UserService userService;

    @Autowired
    public AuthService(EmailTokenRepository emailTokenRepository, EmailService emailService, UserService userService) {
        this.emailTokenRepository = emailTokenRepository;
        this.emailService = emailService;
        this.userService = userService;
    }

    public void registerUser(UserDTO userDTO) {
        // 1. 사용자 저장 (UserService를 사용)
        User user = userService.registerUser(userDTO);

        // 2. 이메일 인증 토큰 생성
        String token = UUID.randomUUID().toString();
        LocalDateTime expirationTime = LocalDateTime.now().plusHours(1); // 24시간 유효
        emailTokenRepository.save(new EmailToken(token, user.getUsername(), expirationTime));

        // 3. 이메일 인증 링크 생성 및 전송
        String link = "https://gungangazi.site/verify-email?token=" + token;
        emailService.sendEmail(
            user.getEmail(),
            "이메일 인증 요청",
            "다음 링크를 클릭하여 이메일을 인증하세요: " + link
        );
    }
}

