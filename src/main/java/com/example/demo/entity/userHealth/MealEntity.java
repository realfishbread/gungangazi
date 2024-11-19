package com.example.demo.entity.userHealth;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "meals")
public class MealEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String username;  // username 필드 추가
    private String date;
    private String meal;

    @Column(name = "calories")
    private int calories;  // 칼로리 필드 추가

    @Column(name = "meal_type")
    private String meal_type;  // 식사/간식 구분 필드 추가


    // 기본 생성자
    public MealEntity() {}

    // 매개변수 있는 생성자
    public MealEntity(String date, String meal, String username, int calories, String meal_type) {
        this.date = date;
        this.meal = meal;
        this.username = username; 
        this.calories = calories; 
        this.meal_type = meal_type;
    }

    // Getter 및 Setter 메소드
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public void setMealType(String meal_type) {
        this.meal_type = meal_type;
    }

    public int getCalories() {
        return calories;
    }

    public void setCalories(int calories) {
        this.calories = calories;
    }
}

