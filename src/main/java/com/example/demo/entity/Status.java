package com.example.demo.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "status")
public class Status {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String username;
    private int water_level;
    private int meal_level;
    private int sleep_level;

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

    public int getWater_level() {
        return water_level;
    }

    public void setWater_level(int water_level) {
        this.water_level = water_level;
    }

    public int getMeal_level() {
        return meal_level;
    }

    public void setMeal_level(int meal_level) {
        this.meal_level = meal_level;
    }

    public int getSleep_level() {
        return sleep_level;
    }

    public void setSleep_level(int sleep_level) {
        this.sleep_level = sleep_level;
    }
}