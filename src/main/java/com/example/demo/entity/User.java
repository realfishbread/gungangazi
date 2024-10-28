package com.example.demo.entity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "users") // 데이터베이스의 "users" 테이블과 매핑
public class User {

    @Id // 레코드를 고유하게 식별
    @GeneratedValue(strategy = GenerationType.IDENTITY) // 데이터베이스가 이 필드의 값을 자동으로 설정되게 만듦
    private String id;

    @Column(name = "username", nullable = false, unique = true) // 사용자명은 null이 아니고 고유해야 함
    private String username;

    @Column(name = "password", nullable = false) // 비밀번호는 null이 아니어야 함
    private String password;

    @Column(name = "email", nullable = false, unique = true) // 이메일은 null이 아니고 고유해야 함
    private String email;


    // Getters and Setters
    public String getId() { // id에 대한 getter
        return id;
    }

    public void setId(String id) { // id에 대한 setter
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String name) {
        this.username = name;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getEmail() { // 이메일에 대한 getter
        return email;
    }

    public void setEmail(String email) { // 이메일에 대한 setter
        this.email = email;
    }

}