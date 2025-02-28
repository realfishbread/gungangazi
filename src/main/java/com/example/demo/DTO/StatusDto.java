package com.example.demo.DTO;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class StatusDto {
    private String username;
    private int water_level;
    private int meal_level;
    private int sleep_level;
}