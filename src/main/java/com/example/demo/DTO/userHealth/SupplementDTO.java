package com.example.demo.DTO.userHealth;

import java.time.LocalDate;

import com.example.demo.entity.userHealth.Supplement;
import com.fasterxml.jackson.annotation.JsonFormat;

public class SupplementDTO {
     @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private LocalDate date;
    private boolean supplement_taken;
    private boolean menstruation_recorded;
    private String username;


    // 기본 생성자
    public SupplementDTO() {}

    // 전체 필드를 초기화하는 생성자
    public SupplementDTO(String username, LocalDate date, boolean supplement_taken, boolean menstruation_recorded) {
        this.date = date;
        this.supplement_taken = supplement_taken;
        this.menstruation_recorded = menstruation_recorded;
        this.username = username;
    }

    // 엔티티 -> DTO 변환 메서드
    public static SupplementDTO fromEntity(Supplement supplement) {
        return new SupplementDTO(
            supplement.getUsername(),
            supplement.getDate(),
            supplement.isSupplement_taken(),
            supplement.isMenstruation_recorded()
        );
    }
    // Getters and Setters
    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public boolean isSupplement_taken() {
        return supplement_taken;
    }

    public void setSupplement_taken(boolean supplement_taken) {
        this.supplement_taken = supplement_taken;
    }

    public boolean isMenstruation_recorded() {
        return menstruation_recorded;
    }

    public void setMenstruation_recorded(boolean menstruation_recorded) {
        this.menstruation_recorded = menstruation_recorded;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }
}
