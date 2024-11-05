package com.example.demo.DTO.userHealth;

public class BrushHistoryDTO {
    private Long id;
    private String username;
    private String date;
    private int duration;
    private boolean flossed;

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

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public boolean isFlossed() {
        return flossed;
    }

    public void setFlossed(boolean flossed) {
        this.flossed = flossed;
    }
}

