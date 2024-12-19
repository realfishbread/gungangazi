package com.example.demo.service;
import java.util.Collections;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Random;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.DTO.UserDTO;
import com.example.demo.entity.EmailToken;
import com.example.demo.repository.userHealth.EmailTokenRepository;

@Service
public class AuthService {

    private final EmailTokenRepository emailTokenRepository;
    private final UserService userService;

    private final Set<String> verifiedEmails = Collections.synchronizedSet(new HashSet<String>());


    @Autowired
    public AuthService(EmailTokenRepository emailTokenRepository, UserService userService) {
        this.emailTokenRepository = emailTokenRepository;
        this.userService = userService;
    }

    public void sendVerificationCode(String email) {
        EmailToken existingToken = emailTokenRepository.findByEmail(email);
        if (existingToken != null && LocalDateTime.now().isBefore(existingToken.getExpiration_time())) {
            throw new IllegalStateException("유효한 인증 코드가 이미 전송되었습니다. 잠시 후 다시 시도하세요.");
        }

        String verificationCode = generateVerificationCode();
        LocalDateTime expirationTime = LocalDateTime.now().plusMinutes(10);

        emailTokenRepository.save(new EmailToken(verificationCode, expirationTime, email));

    }

    public boolean verifyCode(String email, String code) {
        if (code == null || code.isEmpty()) {
            return false;
        }

        EmailToken token = emailTokenRepository.findByEmail(email);

        if (token != null && token.getToken().equals(code) && LocalDateTime.now().isBefore(token.getExpiration_time())) {
            verifiedEmails.add(email);
            emailTokenRepository.delete(token);
            return true;
        }

        if (token != null && LocalDateTime.now().isAfter(token.getExpiration_time())) {
            emailTokenRepository.delete(token);
        }

        return false;
    }

    public boolean registerUserIfVerified(String email, UserDTO userDTO) {
        if (!verifiedEmails.contains(email)) {
            throw new IllegalStateException("이메일 인증이 완료되지 않았습니다.");
        }

        userService.registerUser(userDTO);
        verifiedEmails.remove(email);
        return true;
    }

    private String generateVerificationCode() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(999999));
    }
}


