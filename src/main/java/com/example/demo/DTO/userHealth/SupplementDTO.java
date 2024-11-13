package com.example.demo.DTO.userHealth;

import java.time.LocalDate;

public class SupplementDTO {
    private LocalDate date;
    private boolean supplementTaken;
    private boolean menstruationRecorded;
    private String username;

    // Getters and Setters
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

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }
}
