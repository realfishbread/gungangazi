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
        return new Status(null, username, water_level, meal_level, sleep_level);
    }
}
