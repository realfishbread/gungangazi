package com.example.demo.DTO.userHealth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class SleepDto {
    @NotBlank // 비어있으면 안 되는 필드
    private String date;

    @NotBlank // 비어있으면 안 되는 필드
    private String sleepTime;

    @NotBlank // 비어있으면 안 되는 필드
    private String wakeUpTime;

    @NotNull // Null일 수 없는 필드
    private String username;

    // 기본 생성자 (Spring에서 필요)
    public SleepDto() {}

    // 생성자
    public SleepDto(String date, String sleepTime, String wakeUpTime, String username) {
        this.date = date;
        this.sleepTime = sleepTime;
        this.wakeUpTime = wakeUpTime;
        this.username = username;
    }

    // Getter와 Setter
    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getSleepTime() {
        return sleepTime;
    }

    public void setSleepTime(String sleepTime) {
        this.sleepTime = sleepTime;
    }

    public String getWakeUpTime() {
        return wakeUpTime;
    }

    public void setWakeUpTime(String wakeUpTime) {
        this.wakeUpTime = wakeUpTime;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    // toString 메서드 (디버깅 용도)
    @Override
    public String toString() {
        return "SleepDto{" +
                "date='" + date + '\'' +
                ", sleepTime='" + sleepTime + '\'' +
                ", wakeUpTime='" + wakeUpTime + '\'' +
                ", username='" + username + '\'' +
                '}';
    }
}
