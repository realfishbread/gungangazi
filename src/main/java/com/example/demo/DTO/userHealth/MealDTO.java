package com.example.demo.DTO.userHealth;


public class MealDTO {
    private String date;
    private String meal;

    // 기본 생성자
    public MealDTO() {}

    // 매개변수 있는 생성자
    public MealDTO(String date, String meal) {
        this.date = date;
        this.meal = meal;
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
}
