package com.example.demo.DTO.userHealth;
import com.example.demo.entity.userHealth.MealEntity;

public class MealDTO {
    private String date;
    private String meal;
    private String username;  // username 추가

    // 기본 생성자
    public MealDTO() {}

    // 매개변수 있는 생성자
    public MealDTO(String date, String meal, String username) {
        this.date = date;
        this.meal = meal;
        this.username = username;  // 생성자에 username 추가
    }

    // Getter 및 Setter 메소드
    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getMeal() {
        return meal;
    }

    public void setMeal(String meal) {
        this.meal = meal;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }
    public static MealDTO fromEntity(MealEntity mealEntity) {
        MealDTO dto = new MealDTO();
        dto.setDate(mealEntity.getDate());
        dto.setMeal(mealEntity.getMeal());
        dto.setUsername(mealEntity.getUsername());
        return dto;
    }
}
