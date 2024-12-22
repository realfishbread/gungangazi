package com.example.demo.entity;
import org.springframework.data.annotation.Id;
import org.springframework.data.redis.core.RedisHash;

@RedisHash(value = "EmailVerifyCode", timeToLive = 600) // TTL 설정 (600초 = 10분)
public class EmailVerifyCode {

    @Id
    private String email; // Redis의 Key
    private String code; // Redis의 Value

    public EmailVerifyCode() {}

    public EmailVerifyCode(String email, String code) {
        this.email = email;
        this.code = code;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }
}
