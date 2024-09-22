package com.example.demo.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long memberId;
    private String memberName;
    private String memberEmail;
    private String memberPassword;
    private int memberSex;
    
    public User() {}
    
    // 매개변수 있는 생성자
    public User(String memberName) {
        this.memberName = memberName;
    }

    // Getter and Setter for 'id'
    public Long getId() {
        return memberId;
    }

    public void setId(Long memberId) {
        this.memberId = memberId;
    }

    // Getter and Setter for 'name'
    public String getName() {
        return memberName;
    }

    public void setName(String memberName) {
        this.memberName = memberName;
    }
    

    // Getters and Setters
    
    //키, 몸무게, 성별 추가
}
