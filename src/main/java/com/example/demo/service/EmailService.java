package com.example.demo.service;

import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.thymeleaf.context.Context;
import org.thymeleaf.spring6.SpringTemplateEngine;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;

@Service
public class EmailService {

    private final JavaMailSender mailSender;

    @Autowired
    private SpringTemplateEngine templateEngine; // 템플릿 엔진 주입

    @Autowired
    public EmailService(JavaMailSender mailSender) {
        this.mailSender = mailSender;
    }

    public void sendEmail(String to, String subject, String body) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(body, true); // true로 설정하면 HTML 이메일을 보낼 수 있음

            mailSender.send(message);

            System.out.println("이메일 전송 완료: " + to);
        } catch (MessagingException e) {
            System.err.println("이메일 전송 실패: " + e.getMessage());
            throw new RuntimeException("이메일 전송 중 오류가 발생했습니다.");
        }
    }

    public void sendEmailWithCode(String to, String subject, String code) {
        Context context = new Context();
        context.setVariable("code", code); // 랜덤 인증 코드 추가

        // email-code-template.html 파일을 템플릿으로 사용
        String body = templateEngine.process("email-template", context);

        // HTML 이메일 전송
        sendEmail(to, subject, body);
    }

    public String generateVerificationCode() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(999999)); // 6자리 랜덤 숫자 생성
    }
}