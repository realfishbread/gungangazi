package com.example.demo.DTO;

import java.time.LocalDateTime;

public class VerifyCodeRequestDTO {
    private String email;
    private String token;
    private LocalDateTime expiration_time;
    private boolean email_verified;

    // Getter와 Setter
    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }
    public boolean isEmail_verified() {
        return email_verified;
    }

    public void setEmail_verified(boolean email_verified) {
        this.email_verified = email_verified;
    }
    public LocalDateTime getExpiration_time() {
        return expiration_time;
    }
    
    public void setExpiration_time(LocalDateTime expiration_time) {
        this.expiration_time = expiration_time;
    }
}
