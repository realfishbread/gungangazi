package com.example.demo.entity.userHealth;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.LocalDate;

@Entity
@Table(name = "supplements")
public class Supplement {

    @Id
    private LocalDate date;
    private boolean supplementTaken;
    private boolean menstruationRecorded;

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
}