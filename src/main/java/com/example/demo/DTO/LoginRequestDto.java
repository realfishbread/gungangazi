package com.example.demo.DTO;
 // LoginRequestDto 임포트
import java.util.HashMap; // Map 임포트
import java.util.Map;

public class LoginRequestDto {
    private String username; // 사용자의 아이디
    private String password; // 사용자의 비밀번호

    // 생성자
    public LoginRequestDto(String username, String password) {
        this.username = username;
        this.password = password;
    }

    // Getter 메서드
    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }

    // toJson() 메서드 (JSON 형태로 변환하기 위한 메서드)
    public Map<String, String> toJson() {
        Map<String, String> json = new HashMap<>();
        json.put("username", username);
        json.put("password", password);
        return json;
    }
}