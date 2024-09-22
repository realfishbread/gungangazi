package com.example.demo.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;

@Entity
public class Symptom {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)  // 기본 키 생성 전략
    private Long id;
    
    private String name;
    private int severity;  // 증상의 심각도

    // 기본 생성자
    public Symptom() {
    }

    // 매개변수가 있는 생성자
    public Symptom(String name, int severity) {
        this.name = name;
        this.severity = severity;
    }

    // 게터와 세터
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getSeverity() {
        return severity;
    }

    public void setSeverity(int severity) {
        this.severity = severity;
    }
}