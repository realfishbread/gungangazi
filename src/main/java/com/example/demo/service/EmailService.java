package com.example.demo.service;

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

    public void sendEmailWithTemplate(String to, String subject, String token) {
        Context context = new Context();
        context.setVariable("link", "https://gungangazi.site/verify-email?token=" + token);

        // email-template.html 파일을 템플릿으로 사용
        String body = templateEngine.process("email-template", context);

        // HTML 이메일 전송
        sendEmail(to, subject, body);
    }
}
