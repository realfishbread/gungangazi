package com.example.demo.entity.userHealth;

import java.time.LocalDate;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.IdClass;
import jakarta.persistence.Table;

@Entity
@Table(name = "supplements")
@IdClass(SupplementId.class) 
public class Supplement {

    @Id
    private String username;  // 사용자 이름 (기본키)

    @Id
    private LocalDate date;  // 날짜

    private boolean supplementTaken;  // 영양제 복용 여부
    private boolean menstruationRecorded;  // 생리 기록 여부

    // Getters and Setters
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public boolean isSupplementTaken() {
        return supplementTaken;
    }

    public void setSupplementTaken(boolean supplementTaken) {
        this.supplementTaken = supplementTaken;
    }

    public boolean isMenstruationRecorded() {
        return menstruationRecorded;
    }

    public void setMenstruationRecorded(boolean menstruationRecorded) {
        this.menstruationRecorded = menstruationRecorded;
    }
}
