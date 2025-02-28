package com.example.demo.DTO;

import com.example.demo.entity.Status;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class StatusDto {
    private String username;
    private int water_level;
    private int meal_level;
    private int sleep_level;

    // 모든 필드를 받는 생성자
    public StatusDto(String username, int water_level, int meal_level, int sleep_level) {
        this.username = username;
        this.water_level = water_level;
        this.meal_level = meal_level;
        this.sleep_level = sleep_level;
    }

    // DTO → Entity 변환 메서드
    public Status toEntity() {
        return new Status(username, water_level, meal_level, sleep_level);
    }

    // Getter & Setter (필수)
    public void setWater_level(int water_level) {
        this.water_level = water_level;
    }

    public void setMeal_level(int meal_level) {
        this.meal_level = meal_level;
    }

    public void setSleep_level(int sleep_level) {
        this.sleep_level = sleep_level;
    }

    public int getSleep_level() {
        return sleep_level;
    }

    public int getMeal_level() {
        return meal_level;
    }

    public int getWater_level() {
        return water_level;
    }

}
