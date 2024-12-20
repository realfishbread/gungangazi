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

import jakarta.transaction.Transactional;

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
            emailToken = new EmailToken(email, expirationTime, newCode);
        }

        // 데이터 저장
        emailTokenRepository.save(emailToken);

        return newCode; // 새 코드 반환
    }




    public boolean verifyCode(String email, String code) {
        System.out.println("verifyCode 호출됨: 이메일=" + email + ", 코드=" + code);
    
        if (code == null || code.isEmpty()) {
            System.out.println("코드가 null 또는 비어 있음");
            return false;
        }
    
        EmailToken token = emailTokenRepository.findByEmail(email);
        if (token == null) {
            System.out.println("토큰을 찾을 수 없음");
            return false;
        }
    
        if (token.getToken().equals(code) && LocalDateTime.now().isBefore(token.getExpiration_time())) {
            System.out.println("토큰 검증 성공");
            verifiedEmails.add(email);
            emailTokenRepository.delete(token); // 데이터베이스에서 삭제
            return true;
        }
    
        if (LocalDateTime.now().isAfter(token.getExpiration_time())) {
            System.out.println("토큰 만료됨");
            emailTokenRepository.delete(token); // 만료된 토큰 삭제
        }
    
        System.out.println("토큰 검증 실패");
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


