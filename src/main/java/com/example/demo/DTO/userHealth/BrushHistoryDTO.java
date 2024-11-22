package com.example.demo.DTO.userHealth;

public class BrushHistoryDTO {
    private long id;
    private String username;
    private String date;
    private int duration;
    private boolean flossed;

     // 기본 생성자
     public BrushHistoryDTO() {
    }

     // 모든 필드를 초기화하는 생성자
     public BrushHistoryDTO(int id, String username, String date, int duration, boolean flossed) {
        this.id = id;
        this.username = username;
        this.date = date;
        this.duration = duration;
        this.flossed = flossed;
    }

    // Getters and Setters
    public long getId() {
        return id;
    }

    public void setId(long id) {
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

