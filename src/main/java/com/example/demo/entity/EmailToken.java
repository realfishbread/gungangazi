package com.example.demo.entity;
import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "email_token")
public class EmailToken {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String token;

    private LocalDateTime expiration_time;
     @Column(nullable = false, unique = true)
    private String email; // 이메일 필드 추가

    @Column(name = "email_verified", nullable = false)
    private boolean email_verified; // 기본값: false

    public EmailToken() {
        // 기본 생성자
    }

    public EmailToken(String token, LocalDateTime expiration_time,  String email, boolean email_verified) {
        this.token = token;
        this.expiration_time = expiration_time;
        this.email = email;
        this.email_verified = email_verified;
    }

    public boolean isExpired() {
        return expiration_time.isBefore(LocalDateTime.now());
    }


    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getToken() {
        return token;
    }
    
    public void setToken(String token) {
        this.token = token;
    }
    
    
    public LocalDateTime getExpiration_time() {
        return expiration_time;
    }
    
    public void setExpiration_time(LocalDateTime expiration_time) {
        this.expiration_time = expiration_time;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
    // Getter & Setter
    public boolean isEmail_verified() {
        return email_verified;
    }

    public void setEmail_verified(boolean email_verified) {
        this.email_verified = email_verified;
    }
}
