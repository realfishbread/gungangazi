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
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "username", nullable = false, unique = true) // 사용자명은 null이 아니고 고유해야 함
    private String username;

    @Column(name = "password", nullable = false) // 비밀번호는 null이 아니어야 함
    private String password;

    @Column(name = "email", nullable = false, unique = true) // 이메일은 null이 아니고 고유해야 함
    private String email;

    @Column(name = "realname", nullable = false) // 실명 필드
    private String realname;

    @Column(name = "height", nullable = true) // 키 필드 추가
    private String height;

    @Column(name = "weight", nullable = true) // 몸무게 필드 추가
    private String weight;

    @Column(name = "gender", nullable = true) // 성별 필드 추가
    private String gender;

    @Column(name = "age", nullable = true) // 나이 필드 추가
    private Integer age;

    @Column(name = "profile_image", columnDefinition = "TEXT") // Base64 인코딩된 이미지 저장
    private String profile_image;

    

    public long getId() {
        return id;
    }

    public void setId(long id) {
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

    public String getRealname() { // 실명에 대한 getter
        return realname;
    }

    public void setRealname(String realname) { // 실명에 대한 setter
        this.realname = realname;
    }

    public String getHeight() { // 키에 대한 getter
        return height;
    }

    public void setHeight(String height) { // 키에 대한 setter
        this.height = height;
    }

    public String getWeight() { // 몸무게에 대한 getter
        return weight;
    }

    public void setWeight(String weight) { // 몸무게에 대한 setter
        this.weight = weight;
    }

    public String getGender() { // 성별에 대한 getter
        return gender;
    }

    public void setGender(String gender) { // 성별에 대한 setter
        this.gender = gender;
    }

    public Integer getAge() { // 나이에 대한 getter
        return age;
    }

    public void setAge(Integer age) { // 나이에 대한 setter
        this.age = age;
    }
    public String getProfile_image() {
        return profile_image;
    }

    public void setProfile_image(String profile_image) {
        this.profile_image = profile_image;
    }
}
