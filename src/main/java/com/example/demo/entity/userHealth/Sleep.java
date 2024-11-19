package com.example.demo.entity.userHealth;

import java.time.LocalDate;
import java.time.LocalTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "sleep")
public class Sleep {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String username;

    private LocalDate date;
    private LocalTime sleep_time;
    private LocalTime wake_up_time;

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

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

    public LocalTime getSleep_time() {
        return sleep_time;
    }

    public void setSleep_time(LocalTime sleep_time) {
        this.sleep_time = sleep_time;
    }

    public LocalTime getWake_up_time() {
        return wake_up_time;
    }

    public void setWake_up_time(LocalTime wake_up_time) {
        this.wake_up_time = wake_up_time;
    }
}
