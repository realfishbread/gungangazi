package com.example.demo.entity;
import java.time.LocalDateTime;

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

    private String username; // 연결된 사용자 ID
    private LocalDateTime expiration_time;

    public EmailToken(String token, String username, LocalDateTime expiration_time) {
        this.token = token;
        this.username = username;
        this.expiration_time = expiration_time;
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
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public LocalDateTime getExpiration_time() {
        return expiration_time;
    }
    
    public void setExpiration_time(LocalDateTime expiration_time) {
        this.expiration_time = expiration_time;
    }
}
