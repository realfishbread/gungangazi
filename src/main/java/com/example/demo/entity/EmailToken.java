package com.example.demo.entity;
import java.time.LocalDateTime;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class EmailToken {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String token;

    private String username; // 연결된 사용자 ID
    private LocalDateTime expirationTime;

    public EmailToken(String token, String username, LocalDateTime expirationTime) {
        this.token = token;
        this.username = username;
        this.expirationTime = expirationTime;
    }

    public boolean isExpired() {
        return expirationTime.isBefore(LocalDateTime.now());
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
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public LocalDateTime getExpirationTime() {
        return expirationTime;
    }
    
    public void setExpirationTime(LocalDateTime expirationTime) {
        this.expirationTime = expirationTime;
    }
}
