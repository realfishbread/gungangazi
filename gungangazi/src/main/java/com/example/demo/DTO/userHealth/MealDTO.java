package com.example.demo.DTO.userHealth;

import com.example.demo.entity.userHealth.MealEntity;

public class MealDTO {
    private String id; // id 필드 추가
    private String date;
    private String meal;
    private String username; // username 추가
    private int calories; // 칼로리 필드 추가
    private String meal_type; // 식사/간식 구분 필드 추가

    // 기본 생성자
    public MealDTO() {}

    // 매개변수 있는 생성자
    public MealDTO(String id, String date, String meal, String username, int calories, String meal_type) {
        this.id = id; // id 필드 추가
        this.date = date;
        this.meal = meal;
        this.username = username; // 생성자에 username 추가
        this.calories = calories;
        this.meal_type = meal_type;
    }

    // Getter 및 Setter 메소드
    public String getId() {
        return id; // id Getter
    }

    public void setId(String id) {
        this.id = id; // id Setter
    }

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

    public String getMeal_type() {
        return meal_type;
    }

    public void setMeal_type(String meal_type) {
        this.meal_type = meal_type;
    }

    public int getCalories() {
        return calories;
    }

    public void setCalories(int calories) {
        this.calories = calories;
    }

    public static MealDTO fromEntity(MealEntity mealEntity) {
        MealDTO dto = new MealDTO();
        dto.setId(mealEntity.getId()); // 엔티티의 id 필드를 DTO로 변환
        dto.setDate(mealEntity.getDate());
        dto.setMeal(mealEntity.getMeal());
        dto.setUsername(mealEntity.getUsername());
        dto.setCalories(mealEntity.getCalories());
        dto.setMeal_type(mealEntity.getMeal_type());
        return dto;
    }
}
