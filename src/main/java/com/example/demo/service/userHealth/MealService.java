package com.example.demo.service.userHealth;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.DTO.userHealth.MealDTO;
import com.example.demo.entity.userHealth.MealEntity;
import com.example.demo.repository.userHealth.MealRepository;

@Service
public class MealService {

    private final MealRepository mealRepository;

    @Autowired
    public MealService(MealRepository mealRepository) {
        this.mealRepository = mealRepository;
    }

    // 날짜별 식사 기록 조회
    public List<MealDTO> getAllMealsByUsername(String username) {
        List<MealEntity> meals = mealRepository.findByUsername(username);
        return meals.stream().map(MealDTO::fromEntity).collect(Collectors.toList());
}

    // 새로운 식사 기록 추가
    public void addMeal(MealDTO mealDTO) {
        MealEntity mealEntity = new MealEntity();
        mealEntity.setDate(mealDTO.getDate());
        mealEntity.setMeal(mealDTO.getMeal());
        mealEntity.setUsername(mealDTO.getUsername());
        mealEntity.setCalories(mealDTO.getCalories());  // 칼로리 설정
        mealEntity.setMealType(mealDTO.getMeal_type());  // 식사/간식 구분 설정
        mealRepository.save(mealEntity);
    }

    public void deleteMeal(Long mealId) {
        if (!mealRepository.existsById(mealId)) {
            throw new IllegalArgumentException("Meal not found");
        }
        mealRepository.deleteById(mealId);
    }
}
    
 

