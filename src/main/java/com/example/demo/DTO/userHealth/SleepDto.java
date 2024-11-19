package com.example.demo.DTO.userHealth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class SleepDto {
    @NotBlank // 비어있으면 안 되는 필드
    private String date;

    @NotBlank // 비어있으면 안 되는 필드
    private String sleep_time;

    @NotBlank // 비어있으면 안 되는 필드
    private String wake_up_time;

    @NotNull // Null일 수 없는 필드
    private String username;

    // 기본 생성자 (Spring에서 필요)
    public SleepDto() {}

    // 생성자
    public SleepDto(String date, String sleep_time, String wake_up_time, String username) {
        this.date = date;
        this.sleep_time = sleep_time;
        this.wake_up_time = wake_up_time;
        this.username = username;
    }

    // Getter와 Setter
    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getSleep_time() {
        return sleep_time;
    }

    public void setSleep_time(String sleep_time) {
        this.sleep_time = sleep_time;
    }

    public String getWake_up_time() {
        return wake_up_time;
    }

    public void setWake_up_time(String wake_up_time) {
        this.wake_up_time = wake_up_time;
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
                ", sleepTime='" + sleep_time + '\'' +
                ", wakeUpTime='" + wake_up_time + '\'' +
                ", username='" + username + '\'' +
                '}';
    }
}
