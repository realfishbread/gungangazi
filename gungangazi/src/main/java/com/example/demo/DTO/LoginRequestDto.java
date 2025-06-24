package com.example.demo.DTO;
 // LoginRequestDto 임포트

public class LoginRequestDto {
    private String username;
    private String password;

    // 기본 생성자 (필수)
    public LoginRequestDto() {}

    public LoginRequestDto(String username, String password) {
        this.username = username;
        this.password = password;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }
}