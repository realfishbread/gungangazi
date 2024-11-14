package com.example.demo.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class Status {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String username;
    private int waterLevel;
    private int mealLevel;
    private int sleepLevel;

    // 기본 생성자
    public Status() {}

    // 생성자
    public Status(String username, int waterLevel, int mealLevel, int sleepLevel) {
        this.username = username;
        this.waterLevel = waterLevel;
        this.mealLevel = mealLevel;
        this.sleepLevel = sleepLevel;
    }

    // Getter와 Setter
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public int getWaterLevel() { return waterLevel; }
    public void setWaterLevel(int waterLevel) { this.waterLevel = waterLevel; }
    public int getMealLevel() { return mealLevel; }
    public void setMealLevel(int mealLevel) { this.mealLevel = mealLevel; }
    public int getSleepLevel() { return sleepLevel; }
    public void setSleepLevel(int sleepLevel) { this.sleepLevel = sleepLevel; }
}