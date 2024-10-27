package com.example.demo.DTO;
import com.example.demo.entity.User;

public class UserDTO {
    private String username;
    private String password;
    private String email;
    private String gender; // 필요하다면 추가

    // Getters and Setters
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    // 데이터를 엔티티로 변환하는 메서드
    public User toEntity() {
        User user = new User();
        user.setUsername(this.username);
        user.setPassword(this.password);
        user.setEmail(this.email);
        user.setGender(this.gender);
        return user;
    }
}